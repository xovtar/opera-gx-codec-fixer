# Opera GX Codec Fixer

A lightweight, community-developed utility that fixes H.264/AAC video playback issues in Opera GX on Debian-based Linux distributions.

## Features

- Automatically detects Opera GX's Chromium version.
- Searches for a matching Chromium-major FFmpeg release.
- Downloads a compatible codec candidate.
- Backs up the original `libffmpeg.so` before replacing it.
- Provides a desktop shortcut for future repairs.
- Uses a simple terminal-based interface.

## Supported Linux Distributions

**Tested:** Ubuntu 26.04 x86-64.

Other Debian-based distributions, including Debian, Linux Mint, and Pop!_OS, may be compatible but have not yet been tested.

The current version expects Opera GX's codec library at:

`/usr/lib/x86_64-linux-gnu/opera-gx-stable/libffmpeg.so`

## Installation

1. Download `Opera-GX-Codec-Fixer-Installer.run` from the GitHub Releases section.
2. Right-click the downloaded file, open Properties, and enable **Executable as Program**.
3. Right-click the installer and select **Run as a Program** to launch the installation.
4. The installer sets up the repair script and desktop shortcut.
5. Launch **Opera GX Codec Fix** from the desktop whenever you need to repair video playback.

An internet connection is required to download the codec library. Administrator privileges are required when replacing Opera GX's system files.

**Close Opera GX completely before performing a repair.**

## FFmpeg Source and Credits

This utility uses codec-enabled FFmpeg libraries downloaded from:

**[NW.js FFmpeg Prebuilt](https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt)**

The project retrieves candidate libraries from the NW.js FFmpeg Prebuilt GitHub releases.

Special thanks to the developers and contributors who maintain these builds.

This repository does not claim ownership of the third-party FFmpeg binaries.

## Limitations

- Designed for the standard Debian/Ubuntu-style Opera GX installation.
- Matching Chromium major versions does not guarantee binary compatibility.
- Browser updates may overwrite the repaired codec library.
- Some Linux distributions may require modifications to installation paths.
- The tool modifies Opera GX's installed codec library; use at your own risk.

## Contributing

Contributions are welcome!

Developers are encouraged to fork this project, improve compatibility, report bugs, and submit pull requests.

Support for Arch Linux, Fedora, openSUSE, and additional distributions would be especially welcome.

## License

Opera GX Codec Fixer is licensed under the MIT License.

Third-party FFmpeg binaries are governed by their respective licenses.

## Disclaimer

Opera GX Codec Fixer is an unofficial community project. It is not affiliated with, endorsed by, or supported by Opera Software.
