use std::fs::File;
use std::io::Read;
use std::path::Path;

const MH_MAGIC: u32 = 0xFEED_FACE;
const MH_MAGIC_64: u32 = 0xFEED_FACF;
const MH_CIGAM: u32 = 0xCEFA_EDFE;
const MH_CIGAM_64: u32 = 0xCFFA_EDFE;
const FAT_MAGIC: u32 = 0xCAFE_BABE;
const FAT_CIGAM: u32 = 0xBEBA_FECA;

/// Check if a file is a Mach-O binary by reading magic bytes.
pub fn is_macho(path: &Path) -> bool {
    let mut file = match File::open(path) {
        Ok(f) => f,
        Err(_) => return false,
    };

    let mut magic = [0u8; 4];
    if file.read_exact(&mut magic).is_err() {
        return false;
    }

    let magic_be = u32::from_be_bytes(magic);
    matches!(
        magic_be,
        MH_MAGIC | MH_MAGIC_64 | MH_CIGAM | MH_CIGAM_64 | FAT_MAGIC | FAT_CIGAM
    )
}
