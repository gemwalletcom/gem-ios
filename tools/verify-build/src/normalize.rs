use std::fs;
use std::path::Path;

use anyhow::{Context, Result};
use goblin::mach::load_command::CommandVariant;
use goblin::Object;

/// Run the normalize subcommand: read input, normalize, write output.
pub fn run(input: &Path, output: &Path) -> Result<()> {
    let data = fs::read(input).with_context(|| format!("Cannot read {}", input.display()))?;
    let normalized = normalize_bytes(&data)?;
    fs::write(output, &normalized)
        .with_context(|| format!("Cannot write {}", output.display()))?;
    Ok(())
}

/// Normalize Mach-O bytes in memory. Handles FAT and single-arch binaries.
pub fn normalize_bytes(data: &[u8]) -> Result<Vec<u8>> {
    let mut buf = data.to_vec();

    match Object::parse(data)? {
        Object::Mach(goblin::mach::Mach::Fat(fat)) => {
            for arch in fat.iter_arches().flatten() {
                let offset = arch.offset as usize;
                let size = arch.size as usize;
                if offset + size <= buf.len() {
                    normalize_single_macho(&mut buf, offset)?;
                }
            }
        }
        Object::Mach(goblin::mach::Mach::Binary(_)) => {
            normalize_single_macho(&mut buf, 0)?;
        }
        _ => anyhow::bail!("Not a Mach-O file"),
    }

    // Zero out non-deterministic temp paths embedded in __cstring sections
    // (e.g., "swbuild.tmp.XXXXXXX" where X is random alphanumeric)
    zero_temp_paths(&mut buf);

    Ok(buf)
}

/// Find and zero the random suffix in "swbuild.tmp.XXXXXXXX" patterns.
/// The suffix length varies, so we zero all alphanumeric chars after the needle.
fn zero_temp_paths(buf: &mut [u8]) {
    let needle = b"swbuild.tmp.";
    let mut pos = 0;
    while pos + needle.len() < buf.len() {
        if buf[pos..pos + needle.len()] == *needle {
            let suffix_start = pos + needle.len();
            let mut end = suffix_start;
            while end < buf.len() && buf[end].is_ascii_alphanumeric() {
                end += 1;
            }
            if end > suffix_start {
                buf[suffix_start..end].fill(b'0');
            }
            pos = end;
        } else {
            pos += 1;
        }
    }
}

/// Normalize a single Mach-O binary at the given offset within the buffer.
fn normalize_single_macho(buf: &mut [u8], base: usize) -> Result<()> {
    let slice = &buf[base..];
    let macho = goblin::mach::MachO::parse(slice, 0)?;

    for cmd in &macho.load_commands {
        let cmd_offset = base + cmd.offset;

        match cmd.command {
            CommandVariant::Uuid(_) => {
                // Zero out the 16-byte UUID (starts at offset 8 in the command)
                let uuid_start = cmd_offset + 8;
                let uuid_end = uuid_start + 16;
                if uuid_end <= buf.len() {
                    buf[uuid_start..uuid_end].fill(0);
                }
            }
            CommandVariant::CodeSignature(sig_cmd) => {
                // Zero out the signature data block
                let data_start = base + sig_cmd.dataoff as usize;
                let data_end = data_start + sig_cmd.datasize as usize;
                if data_end <= buf.len() {
                    buf[data_start..data_end].fill(0);
                }
            }
            CommandVariant::BuildVersion(bv_cmd) => {
                // Zero out tool versions (each 8 bytes, after the 24-byte command header)
                let tools_start = cmd_offset + 24; // sizeof build_version_command
                for i in 0..bv_cmd.ntools {
                    // Each build_tool_version is 8 bytes: 4 tool + 4 version
                    // Zero the version field (second u32)
                    let version_offset = tools_start + (i as usize * 8) + 4;
                    if version_offset + 4 <= buf.len() {
                        buf[version_offset..version_offset + 4].fill(0);
                    }
                }
            }
            CommandVariant::SourceVersion(_) => {
                // Zero out the 8-byte version field (at offset 8 in the command)
                let version_start = cmd_offset + 8;
                let version_end = version_start + 8;
                if version_end <= buf.len() {
                    buf[version_start..version_end].fill(0);
                }
            }
            _ => {}
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn normalize_non_macho_returns_error() {
        let data = b"not a macho file at all";
        assert!(normalize_bytes(data).is_err());
    }
}
