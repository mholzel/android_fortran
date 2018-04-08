API=24
declare -a LANGUAGES=("c" "cpp" "f")
declare -a SYSTEMS=("arm64" 
                    "arm" 
                    "mips64" 
                    "mips" 
                    "x86" 
                    "x86_64")

# We want to color the font to differentiate our comments from other stuff
normal="\e[0m"
colored="\e[104m"
BASE=${PWD}

for LANGUAGE in "${LANGUAGES[@]}" ; do
    for SYSTEM in "${SYSTEMS[@]}" ; do

        echo -e "${colored}Building ${LANGUAGE} for ${SYSTEM}${normal}" && echo
        mkdir -p ${BASE}/${LANGUAGE}/build/${SYSTEM}
        cd ${BASE}/${LANGUAGE}/build/${SYSTEM}
        cmake ../.. -DTOOLCHAIN_DIR=${BASE}/../standalone_toolchains/${SYSTEM}/${API} -DCMAKE_TOOLCHAIN_FILE=../../../toolchains/${SYSTEM}.cmake
        make 
    
    done
done 

cd ${BASE}