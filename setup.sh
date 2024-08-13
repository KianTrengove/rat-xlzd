#!/bin/bash

# Since system dependencies, especially on clusters, are a pain
# Lets just pre-install everything (except GCC for now).

# Todo:
# --help, -h

exec > >(tee -i install.log)
exec 2>&1

function install(){
    ## Array of installables
    declare -a install_options=("cmake" "root" "geant4" "nlopt" "ratpac")
    declare -A install_selection
    for element in "${install_options[@]}"
    do
        install_selection[$element]=true
    done
    # Versioning
    root_branch="v6-28-00-patches"
    geant_branch="v11.1.2"
    ratpac_repository="https://github.com/rat-pac/ratpac-two.git"

    help $@
    procuse=$(getnproc $@)
    # End testing
    export CC=$(command -v gcc)
    export CXX=$(command -v g++)

    # Check requirements; Git && GCC
    if ! [ -x "$(command -v gcc)" ]; then
        echo "gcc not installed"
        exit 1
    fi
    if ! [ -x "$(command -v git)" ]; then
        echo "git not installed"
        exit 1
    fi

    outfile="env.sh"
    prefix=$(pwd -P)/local
    mkdir -p $prefix/bin
    export PATH=$prefix/bin:$PATH
    export LD_LIBRARY_PATH=$prefix/lib:$LD_LIBRARY_PATH
    printf "export PATH=$prefix/bin:\$PATH\n" > $outfile
    printf "export LD_LIBRARY_PATH=$prefix/lib:\$LD_LIBRARY_PATH\n" >> $outfile
    printf "export CC=$CC\n" >> $outfile
    printf "export CXX=$CXX\n" >> $outfile
    
    cleanup=true
    boolOnly=false
    
    for element in $@;
    do
        if [ "$skipping" = true ]
        then
            # Check if element in install_options
            if [[ " ${install_options[@]} " =~ " ${element} " ]]
            then
                install_selection[$element]=false
            fi
        fi
        if [ $element == "--skip" ]
        then
            skipping=true;
        fi
    done
    
    for element in $@;
    do
        if [ "$boolOnly" = true ]
        then
            if [[ " ${install_options[@]} " =~ " ${element} " ]]
            then
                install_selection[$element]=true
            fi
        fi
        if [ $element == "--only" ]
        then
            # Only will overwrite the skipping rules
            boolOnly=true
            # Set all to false
            for element in "${install_options[@]}"
            do
                install_selection[$element]=false
            done
        fi
        if [ $element == "--noclean" ]
        then
            cleanup=false
        fi
    done

    # global options dictionary
    declare -A options=(["procuse"]=$procuse ["prefix"]=$prefix ["root_branch"]=$root_branch \
        ["geant_branch"]=$geant_branch ["ratpac_repository"]=$ratpac_repository ["cleanup"]=$cleanup)
        
    if [ "${install_selection[cmake]}" = true ]
    then
        install_cmake
    fi

    if [ "${install_selection[root]}" = true ]
    then
        install_root
    fi

    if [ "${install_selection[geant4]}" = true ]
    then
        install_geant4
    fi

    if [ "${install_selection[nlopt]}" = true ]
    then
        install_nlopt
    fi

    if [ "${install_selection[ratpac]}" = true ]
    then
        install_ratpac
    fi
    
    printf "pushd $prefix/bin 2>&1 >/dev/null\nsource thisroot.sh\nsource geant4.sh\npopd 2>&1 >/dev/null\n" >> $outfile
    printf "if [ -f \"$prefix/../ratpac/ratpac.sh\" ]; then\nsource $prefix/../ratpac/ratpac.sh\nfi\n" >> $outfile
    printf "if [ -f \"$prefix/../pyrat/bin/activate\" ]; then\nsource $prefix/../pyrat/bin/activate\nfi\n" >> $outfile
    echo "Done"
}

function help()
{
    declare -A help_options=(["only"]="Only install the following packages" \
        ["skip"]="Skip the following packages")
    for element in $@
    do
        if [[ $element =~ "-h" ]];
        then
            printf "\nAvailable Packages\n"
            # Print out the install options as comma separated list
            printf "%s, " "${install_options[@]}"
            printf "\n\nOptions\n"
            for key in "${!help_options[@]}"
            do
                printf "%-20s%-20s\n" --$key "${help_options[$key]}"
            done
            exit 0
        fi
    done
}

function getnproc()
{
    local nproc=1
    for element in $@
    do
        if [[ $element =~ "-j" ]];
        then
            nproc=$(echo $element | sed -e 's/-j//g')
        fi
    done
    echo $nproc
}

function command_exists()
{
    if (command -v $1 > /dev/null )
    then
        true
    else
        false
    fi
}

function check_deps()
{
    bool=true
    # Before trying to install anything, confirm a list of dependencies
    echo "Checking list of dependencies ..."
    cmds=(gcc openssl curl)
    for c in ${cmds[@]}
    do
        if command_exists $c
        then
            printf "%-30s%-20s\n" $c "Installed"
        else
            printf "%-30s%-20s\n" $c "NOT AVAILABLE"
            bool=false
        fi
    done
    # Check libraries with ldd
    echo "Checking for libraries ..."
    libraries=(libX11 libXpm libXft libffi libXext libQt libOpenGL)
    for lb in ${libraries[@]}
    do
        if check_lib $lb
        then
            printf "%-30s%-20s\n" $lb "Installed"
        else
            printf "%-30s%-20s\n" $lb "NOT AVAILABLE"
            bool=false
        fi
    done
    echo "Dependencies look to be in check"

    $bool
}

function check_lib()
{
    if (ldconfig -p | grep -q $1)
    then
        true
    else
        false
    fi
}

function skip_check()
{
    bool=false
    for elem in $@
    do
        if [[ $elem = "--skip-checks" ]];
        then
            printf "Skipping dependency checker\n"
            bool=true
        fi
    done
    $bool
}

## Installation commands

function install_cmake()
{
    git clone https://github.com/Kitware/CMake.git --single-branch --branch v3.22.0 cmake_src
    mkdir -p cmake_build
    cd cmake_build
    ../cmake_src/bootstrap --prefix=../local \
        && make -j${options[procuse]} \
        && make install
    cd ../
    # Check if cmake was successful, if so clean-up, otherwise exit
    if test -f ${options[prefix]}/bin/cmake
    then
        printf "Cmake install successful\n"
    else
        printf "Cmake install failed ... check logs\n"
        exit 1
    fi
    if [ "${options[cleanup]}" = true ]
    then
        rm -rf cmake_src cmake_build
    fi
}

function install_root()
{
    git clone https://github.com/root-project/root.git --depth 1 --single-branch --branch ${options[root_branch]} root_src
    mkdir -p root_build
    cd root_build
    cmake -DCMAKE_INSTALL_PREFIX=${options[prefix]} -D xrootd=OFF -D roofit=OFF -D minuit2=ON\
            ../root_src \
        && make -j${options[procuse]} \
        && make install
    cd ../
    # Check if root was successful, if so clean-up, otherwise exit
    if test -f ${options[prefix]}/bin/root
    then
        printf "Root install successful\n"
    else
        printf "Root install failed ... check logs\n"
        exit 1
    fi
    if [ "${options[cleanup]}" = true ]
    then
        rm -rf root_src root_build
    fi
}

function install_geant4()
{
    git clone https://github.com/geant4/geant4.git --depth 1 --single-branch --branch ${options[geant_branch]} geant_src
    mkdir -p geant_build
    cd geant_build
    cmake -DCMAKE_INSTALL_PREFIX=${options[prefix]} ../geant_src -DGEANT4_BUILD_EXPAT=OFF \
        -DGEANT4_BUILD_MULTITHREADED=OFF -DGEANT4_USE_QT=ON -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_PYTHON=ON \
        -DGEANT4_BUILD_TLS_MODEL=global-dynamic \
        -DGEANT4_INSTALL_DATA_TIMEOUT=15000 -DGEANT4_USE_GDML=ON \
        && make -j${options[procuse]} \
        && make install
    cd ../
    # Check if g4 was successful, if so clean-up, otherwise exit
    if test -f ${options[prefix]}/bin/geant4-config
    then
        printf "G4 install successful\n"
    else
        printf "G4 install failed ... check logs\n"
        exit 1
    fi
    if [ "${options[cleanup]}" = true ]
    then
        rm -rf geant_src geant_build
    fi
}

function install_ratpac()
{
    # Install rat-pac
    source ${options[prefix]}/bin/thisroot.sh
    source ${options[prefix]}/bin/geant4.sh
    if [[ -f "${options[prefix]}/lib/libCRY.so" ]];
    then
        export CRYLIB=${options[prefix]}/lib
        export CRYINCLUDE=${options[prefix]}/include/cry
        export CRYDATA=${options[prefix]}/data/cry
    fi
    rm -rf ratpac
    git clone ${options[ratpac_repository]} ratpac
    cd ratpac
    make -j${options[procuse]} && source ./ratpac.sh
    # Check if ratpac was successful, if so clean-up, otherwise exit
    if test -f build/bin/rat
    then
        printf "Ratpac install successful\n"
    else
        printf "Ratpac install failed ... check logs\n"
        exit 1
    fi
    cd ../
    mv -v ./ratdb/* ./ratpac/ratdb
    mv -v ./macros/* ./ratpac/macros
    mv -v ./python/* ./ratpac/python
    
}

function install_nlopt()
{
    git clone https://github.com/stevengj/nlopt.git
    pushd nlopt
    cmake -DCMAKE_INSTALL_PREFIX=${options[prefix]} . -Bbuild
    cmake --build build --target install
    popd
    rm -rf nlopt
}


## Main function with checks
if skip_check $@
then
    install $@
else
    if check_deps
    then
        install $@
    else
        printf "\033[31mPlease install system dependencies as indicated above.\033[0m\n"
        printf "\033[31mYou can skip these checks by passing the --skip-checks flag.\033[0m\n"
    fi
fi
