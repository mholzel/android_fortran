# Specify NDK release and API that you want to use. 
NDK_RELEASE="r13b"
API="24"

# We want to color the font to differentiate our comments from other stuff
normal="\e[0m"
colored="\e[104m"

declare -a SYSTEMS=("arm64" 
                    "arm" 
                    "mips64" 
                    "mips" 
                    "x86" 
                    "x86_64")
declare -a HEADERS=("aarch64-linux-android"
                    "arm-linux-androideabi"
                    "mips64el-linux-android"
                    "mipsel-linux-android"
                    "x86"
                    "x86_64")
N_SYSTEMS=${#SYSTEMS[@]}
                    
# Save the base directory 
BASE=$PWD
ARCHIVES=${BASE}/archives
mkdir -p ${ARCHIVES}

# See if we have already downloaded and unpacked the ndk
NDK=${BASE}/android-ndk-${NDK_RELEASE}
NDK_ZIP=android-ndk-${NDK_RELEASE}-linux-x86_64.zip
if [ ! -d ${NDK} ]; then

    # If we don't have it, download the ndk
    if [ ! -f ${ARCHIVES}/${NDK_ZIP} ]; then

        echo -e "${colored}Downloading the NDK${normal}" && echo
        wget https://dl.google.com/android/repository/${NDK_ZIP} -P ${ARCHIVES}
    fi 

    # Now unpack the compressed file, printing a dot for every 100th file that gets unzipped
    if which unzip > /dev/null; then
        echo ""
    else
        echo -e "${colored}To unpack the NDK, we need 'unzip'. Please give us sudo rights to install it." && echo 
        sudo apt install -y unzip
        echo ""
    fi

    echo -e "${colored}Unpacking the NDK. This can take a very long time. Here is a dot for every 100th unpacked file:${normal}" && echo 
    unzip ${ARCHIVES}/${NDK_ZIP} | awk 'BEGIN {ORS=" "} {if(NR%100==0)print "."}'
    echo ""
    
fi

# Finally, build the standalone toolchains
for (( i=0; i<${N_SYSTEMS}; i++ )) ; do 

    # If we don't have it, create the toolchain
    TOOLCHAIN=$BASE/standalone_toolchains/${SYSTEMS[$i]}/${API}
    if [ ! -d ${TOOLCHAIN} ]; then
    
        # If we don't have the compressed partial toolchain, download it  
        if [ ! -f ${ARCHIVES}/${HEADERS[$i]}-4.9-partial.7z ] ; then

            echo -e "${colored}Downloading the partial toolchain ${HEADERS[$i]}${normal}" && echo
            wget https://github.com/jeti/android_fortran/releases/download/partial_toolchains/${HEADERS[$i]}-4.9-partial.7z -P ${ARCHIVES}
            echo -e "${colored}Downloaded the partial toolchain ${HEADERS[$i]}${normal}" && echo
        fi
        
        # Now unpack the new version, overwriting any existing files 
        echo -e "${colored}Unpacking the partial toolchain ${HEADERS[$i]} into the ndk distribution${normal}" && echo
        PARTIAL=${NDK}/toolchains/${HEADERS[$i]}-4.9/prebuilt
        7z x ${ARCHIVES}/${HEADERS[$i]}-4.9-partial.7z -o${PARTIAL} -aoa > 7z.log
        rm 7z.log
        echo -e "${colored}Unpacked the partial toolchain ${HEADERS[$i]} into the ndk distribution${normal}" && echo

        # Now create the standalone toolchain
        echo -e "${colored}Creating the standalone toolchain for system=${SYSTEMS[$i]}, api=${API}${normal}" && echo
        ${NDK}/build/tools/make_standalone_toolchain.py --arch ${SYSTEMS[$i]} --api ${API} --install-dir ${TOOLCHAIN}
    fi
    
done

for (( i=0; i<${N_SYSTEMS}; i++ )) ; do 

    # If we didn't compress the toolchain yet, do it now 
    if [ ! -f ${ARCHIVES}/${HEADERS[$i]}-4.9.7z ] ; then

        TOOLCHAIN=$BASE/standalone_toolchains/${SYSTEMS[$i]}/${API}
        echo -e "${colored}Compressing the standalone toolchain ${HEADERS[$i]}. This can take a very long time. Here is a dot for every 100th compressed file:${normal}" && echo 
        7z a -t7z ${ARCHIVES}/${HEADERS[$i]}-4.9.7z -m0=lzma2 -mx=9 -aoa "${TOOLCHAIN}/*" | awk 'BEGIN {ORS=" "} {if(NR%100==0)print "."}'
        echo ""
    fi
done
