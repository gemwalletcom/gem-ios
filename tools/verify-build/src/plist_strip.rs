use std::path::Path;

use anyhow::Result;
use plist::Value;

/// Plist keys that are non-deterministic build metadata.
const STRIP_KEYS: &[&str] = &[
    "BuildMachineOSBuild",
    "DTXcode",
    "DTXcodeBuild",
    "DTPlatformBuild",
    "DTSDKBuild",
    "DTCompiler",
    "DTSDKName",
];

/// Read a plist file, strip non-deterministic keys, return normalized XML bytes.
/// Falls back to raw bytes if the file is not a valid plist.
pub fn normalize_plist(path: &Path) -> Result<Vec<u8>> {
    let data = std::fs::read(path)?;
    match Value::from_reader(std::io::Cursor::new(&data)) {
        Ok(value) => {
            let stripped = strip_keys(value);
            let mut buf = Vec::new();
            stripped.to_writer_xml(&mut buf)?;
            Ok(buf)
        }
        Err(_) => Ok(data),
    }
}

fn strip_keys(value: Value) -> Value {
    match value {
        Value::Dictionary(dict) => {
            let mut new_dict = plist::Dictionary::new();
            for (key, val) in dict {
                if !STRIP_KEYS.contains(&key.as_str()) {
                    new_dict.insert(key, strip_keys(val));
                }
            }
            Value::Dictionary(new_dict)
        }
        Value::Array(arr) => Value::Array(arr.into_iter().map(strip_keys).collect()),
        other => other,
    }
}
