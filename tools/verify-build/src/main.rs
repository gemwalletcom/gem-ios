mod compare;
mod macho;
mod normalize;
mod plist_strip;

use std::path::PathBuf;
use std::process;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "verify-build", about = "Reproducible build verification tools")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Normalize a Mach-O binary by zeroing non-deterministic sections
    Normalize {
        /// Input Mach-O file
        input: PathBuf,
        /// Output normalized file
        output: PathBuf,
    },
    /// Compare two IPA files for reproducible build verification
    Compare {
        /// First IPA file
        ipa1: PathBuf,
        /// Second IPA file
        ipa2: PathBuf,
    },
}

fn main() {
    let cli = Cli::parse();

    let exit_code = match cli.command {
        Commands::Normalize { input, output } => match normalize::run(&input, &output) {
            Ok(()) => 0,
            Err(e) => {
                eprintln!("Error: {e:#}");
                2
            }
        },
        Commands::Compare { ipa1, ipa2 } => match compare::run(&ipa1, &ipa2) {
            Ok(true) => 0,
            Ok(false) => 1,
            Err(e) => {
                eprintln!("Error: {e:#}");
                2
            }
        },
    };

    process::exit(exit_code);
}
