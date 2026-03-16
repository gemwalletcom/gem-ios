use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use walkdir::WalkDir;

use crate::macho;
use crate::normalize;
use crate::plist_strip;

/// Path components to skip entirely.
const SKIP_PATTERNS: &[&str] = &["_CodeSignature", "embedded.mobileprovision", "SC_Info"];

/// Extensions that may differ due to App Store processing (warn only).
const WARN_EXTENSIONS: &[&str] = &[".car", ".nib"];

/// Run the compare subcommand. Returns Ok(true) if equal, Ok(false) if different.
pub fn run(ipa1: &Path, ipa2: &Path) -> Result<bool> {
    for path in [ipa1, ipa2] {
        anyhow::ensure!(path.is_file(), "File not found: {}", path.display());
    }

    let tmp = tempfile::tempdir().context("Failed to create temp directory")?;

    let dir1 = tmp.path().join("ipa1");
    let dir2 = tmp.path().join("ipa2");

    println!("Extracting {}...", ipa1.display());
    extract_zip(ipa1, &dir1)?;

    println!("Extracting {}...", ipa2.display());
    extract_zip(ipa2, &dir2)?;

    let app1 = find_app_dir(&dir1)?;
    let app2 = find_app_dir(&dir2)?;

    let files1 = collect_files(&app1);
    let files2 = collect_files(&app2);

    let only_in_1: BTreeSet<_> = files1.difference(&files2).collect();
    let only_in_2: BTreeSet<_> = files2.difference(&files1).collect();
    let common: BTreeSet<_> = files1.intersection(&files2).collect();

    let mut differences = Vec::new();
    let mut warnings = Vec::new();

    for f in &only_in_1 {
        if !should_skip(f) {
            differences.push(format!("ONLY IN IPA1: {f}"));
        }
    }

    for f in &only_in_2 {
        if !should_skip(f) {
            differences.push(format!("ONLY IN IPA2: {f}"));
        }
    }

    let mut compared = 0u32;

    for relpath in &common {
        if should_skip(relpath) {
            continue;
        }

        let path1 = app1.join(relpath);
        let path2 = app2.join(relpath);
        compared += 1;

        let is_plist = relpath.ends_with(".plist");
        let is_mach = macho::is_macho(&path1);

        let (data1, data2) = if is_plist {
            (
                plist_strip::normalize_plist(&path1)?,
                plist_strip::normalize_plist(&path2)?,
            )
        } else if is_mach {
            let raw1 = fs::read(&path1)?;
            let raw2 = fs::read(&path2)?;
            (
                normalize::normalize_bytes(&raw1).unwrap_or(raw1),
                normalize::normalize_bytes(&raw2).unwrap_or(raw2),
            )
        } else {
            (fs::read(&path1)?, fs::read(&path2)?)
        };

        if data1 != data2 {
            if is_warn_only(relpath) {
                warnings.push(format!("WARNING (expected): {relpath}"));
            } else {
                differences.push(format!(
                    "DIFFERS: {relpath} ({} vs {} bytes)",
                    data1.len(),
                    data2.len()
                ));
            }
        }
    }

    // Print report
    println!();
    println!("{}", "=".repeat(60));
    println!("  IPA Comparison Report");
    println!("{}", "=".repeat(60));
    println!("  IPA 1: {}", ipa1.display());
    println!("  IPA 2: {}", ipa2.display());
    println!("  Files compared: {compared}");
    println!();

    if !warnings.is_empty() {
        println!("  Warnings (expected differences):");
        for w in &warnings {
            println!("    {w}");
        }
        println!();
    }

    if !differences.is_empty() {
        println!("  DIFFERENCES FOUND ({}):", differences.len());
        for d in &differences {
            println!("    {d}");
        }
        println!();
        println!("  RESULT: DIFFERENT");
        println!("{}", "=".repeat(60));
        Ok(false)
    } else {
        println!("  RESULT: EQUIVALENT");
        println!("{}", "=".repeat(60));
        Ok(true)
    }
}

fn extract_zip(zip_path: &Path, dest: &Path) -> Result<()> {
    let file = fs::File::open(zip_path)?;
    let mut archive = zip::ZipArchive::new(file)?;
    archive.extract(dest)?;
    Ok(())
}

fn find_app_dir(extract_dir: &Path) -> Result<PathBuf> {
    let payload = extract_dir.join("Payload");
    anyhow::ensure!(
        payload.exists(),
        "No Payload directory found in IPA"
    );

    for entry in fs::read_dir(&payload)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_dir() {
            if let Some(name) = path.file_name().and_then(|n| n.to_str()) {
                if name.ends_with(".app") {
                    return Ok(path);
                }
            }
        }
    }

    anyhow::bail!("No .app bundle found in Payload/")
}

fn collect_files(app_dir: &Path) -> BTreeSet<String> {
    let mut files = BTreeSet::new();
    for entry in WalkDir::new(app_dir).into_iter().filter_map(|e| e.ok()) {
        if entry.file_type().is_file() {
            if let Ok(rel) = entry.path().strip_prefix(app_dir) {
                files.insert(rel.to_string_lossy().into_owned());
            }
        }
    }
    files
}

fn should_skip(relpath: &str) -> bool {
    SKIP_PATTERNS
        .iter()
        .any(|pat| relpath.split('/').any(|part| part == *pat))
}

fn is_warn_only(relpath: &str) -> bool {
    WARN_EXTENSIONS.iter().any(|ext| relpath.ends_with(ext))
}
