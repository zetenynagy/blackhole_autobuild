# BlackHole AutoBuild
This is a user-friendly bash script for customizing and building the open-source macOS audio loopback driver [BlackHole](https://github.com/ExistentialAudio/BlackHole).

The script is meant to be used for user-friendly customization of the loopback driver, as well as rapid deployment over multiple machines that require different configurations of the driver.

### Customizable attributes:
* Driver name
* Audio device name
* Audio device channel count
* Bundle identifier

## Usage
1. Download or clone the repository
2. Navigate into the folder where the script is located
3. Run the script using `sudo`

e.g.:

`cd ~/Downloads/blackhole_autobuild-main`

`sudo ./BlackHole_autobuild.sh`

Press 1 or 2 when prompted for a yes/no question, and enter text when prompted.


## Dependencies
The script automatically fetches and optionally installs dependencies if they are not found.

The script depends on:
* `xcode-select`, which ships with macOS
* `xcodebuild`, which is installed with Xcode, or as a part of the Xcode Command Line Tools
* `git`, which is installed with Xcode, or as a part of the Xcode Command Line Tools, or e.g. using Homebrew
