#! /bin/bash

# check if user has root access
if [[ $EUID -ne 0 ]]; then
    isRoot=false
else   
    isRoot=true
fi

# check if xcode-select is installed
if ! command -v xcode-select >/dev/null 2>&1
then
    echo -e "\033[91mfatal: \033[39mxcode-select could not be found, terminating"
    exit 1
else
    xcodeSelectVersion="$(xcode-select --version)"
    echo -e "\n\033[92mxcode-select found, $xcodeSelectVersion\n"
fi

# check if xcode command line tools are installed, install them if not
xcodeCommandLineToolsInstalled="$(xcode-select -p 1>/dev/null;echo $?)"
if [[ "$xcodeCommandLineToolsInstalled" == 0 ]]
then
echo -e "\033[92mXcode Command Line Tools found\n"
else
echo -e "\033[93;39mXcode Command Line Tools not found"
echo -e "\033[1mWould you like to install Xcode Command Line Tools?\033[0;39m"
    select strictreply in "Yes" "No"; do
        relaxedreply=${strictreply:-$REPLY}
        case $relaxedreply in
            Yes | yes | Y | y ) xcode-select --install; break;;
            No | no | N | n ) echo "Terminated by user"; exit 1;
        esac
    done
fi

# check if git is installed, should come with xcode command line tools
if ! command -v git >/dev/null 2>&1
then
    echo -e "\033[0;39mgit could not be found"
    exit 1
else
    gitVersion="$(git --version)"
    echo -e "\033[0;92mgit found, $gitVersion\n"
fi

# check if the blackhole repo is in place
if [ ! -d "BlackHole" ]; then
  echo -e "\033[0;39mBlackHole source folder not found."
  echo -e "\033[1mWould you like to clone the BlackHole repository?\033[0;39m"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
        Yes | yes | Y | y ) git clone https://github.com/ExistentialAudio/BlackHole > /dev/null 2>&1; break;;
        No | no | N | n ) echo -e "\033[0;39mTerminated by user"; exit 1;
    esac
done
fi
cd BlackHole;
blackHoleVersion="$(cat VERSION)"
echo -e "\033[0;39mDetected BlackHole source version $blackHoleVersion"
echo -e "\n\033[1mEnter name of driver"
read driverName
echo -e "\n\033[1mEnter display name of audio device"
read deviceName
echo -e "\n\033[1mEnter total number of channels"
read channelNumberUserInput
case "$channelNumberUserInput" in
    ''|*[!0-9]*) echo -e "\033[0;39mNot a valid channel count"; exit 1 ;;
    *) declare -i channelNumber=$channelNumberUserInput;
esac
echo -e "\n\033[1mDo you want to customize the bundle identifier for driver $driverName?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
        Yes | yes | Y | y ) echo -e "\033[1mEnter custom bundle identifier:"; read customBundleID; bundleID=$customBundleID; break;;
        No | no | N | n ) bundleID="audio.existential.BlackHole"; break;;
    esac
done
echo -e "\n\033[1mDo you want to build driver $driverName?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
        Yes | yes | Y | y ) xcodebuild \
  -project BlackHole.xcodeproj \
  -configuration Release \
  PRODUCT_BUNDLE_IDENTIFIER=$bundleID \
  CODE_SIGN_IDENTITY="" \
  DEVELOPMENT_TEAM="" \
  GCC_PREPROCESSOR_DEFINITIONS='$GCC_PREPROCESSOR_DEFINITIONS
  kDriver_Name=\"'$driverName'\"
  kPlugIn_BundleID=\"'$bundleID'\"
  kDevice_Name=\"'$deviceName'\"
  kNumber_Of_Channels='$channelNumber | true
  cp -rp build/Release/BlackHole.driver build/Release/$driverName.driver
  break;;
        No | no | N | n ) echo -e "\033[0;39mTerminated by user"; exit 0;; 
    esac
done
echo -e "\033[1mWould you like to copy the new driver to the system drivers directory?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
        Yes | yes | Y | y ) cp -rp build/Release/$driverName.driver /Library/Audio/Plug-Ins/HAL; 
        
            echo -e "\033[1mWould you like to restart CoreAudio now?"
            select strictreply in "Yes" "No"; do
                relaxedreply=${strictreply:-$REPLY}
                case $relaxedreply in
                    Yes | yes | Y | y ) killall -9 coreaudiod; break;;
                    No | no | N | n ) break;;
                esac
            done
        
        break;;
        No | no | N | n ) break;;
    esac
done
echo -e "\033[1mWould you like to delete the directory containing the BlackHole source?"
select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
        Yes | yes | Y | y ) cd ..; rm -rf BlackHole; 
        break;;
        No | no | N | n ) break;;
    esac
done

