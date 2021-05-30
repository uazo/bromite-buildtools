#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

#sudo apt-get install python
#sudo apt-get install wiggle
sudo apt-get install lftp

echo -e ${RED} -------- download bromite repo ${NC}
git clone https://github.com/bromite/bromite
cd bromite
git fetch
git pull

VERSION=$( cat ./build/RELEASE )
echo -e ${RED} -------- chromium version is: $VERSION ${NC}

echo -e ${RED} -------- cloning depot_tools ${NC}
cd ..
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

echo -e ${RED} -------- apply depot_tools patch ${NC}
cd depot_tools/
git apply ../bromite-buildtools/depot_tools.diff
cd ..

echo -e ${RED} -------- set envs ${NC}
PATH=$PWD/chromium/src/third_party/llvm-build/Release+Asserts/bin:$PWD/depot_tools/:/usr/local/go/bin:$PATH

echo -e ${RED} -------- download chromium pre-prepared ${NC}
rm chromium.$VERSION.tar.gz
#wget -qO- ftp://$FTP_USER:$FTP_PWD@$FTP_HOST/bromite/chromium.$VERSION.tar.gz | tar xz - && OK=1 || OK=0
lftp $FTP_HOST -u $FTP_USER,$FTP_PWD -e "set ftp:ssl-force true; set ssl:verify-certificate false; cd /bromite; get chromium.$VERSION.tar.gz; quit" && OK=1 || OK=0
if [[ OK -eq 0 ]]; then
    echo -e ${RED} -------- not found ${NC}

    echo -e ${RED} -------- download chromium repo ${NC}
    mkdir ./chromium
    cd ./chromium

    gclient root

    mkdir ./src
    cd ./src

    git init
    git remote add origin https://chromium.googlesource.com/chromium/src.git

    git fetch --depth 2 https://chromium.googlesource.com/chromium/src.git +refs/tags/$VERSION:chromium_$VERSION
    git checkout $VERSION
    VERSION_SHA=$( git show-ref -s $VERSION | head -n1 )

    echo >../.gclient "solutions = ["
    echo >>../.gclient "  { \"name\"        : 'src',"
    echo >>../.gclient "    \"url\"         : 'https://chromium.googlesource.com/chromium/src.git@$VERSION_SHA',"
    echo >>../.gclient "    \"deps_file\"   : 'DEPS',"
    echo >>../.gclient "    \"managed\"     : True,"
    echo >>../.gclient "    \"custom_deps\" : {"
    echo >>../.gclient "    },"
    echo >>../.gclient "    \"custom_vars\": {},"
    echo >>../.gclient "  },"
    echo >>../.gclient "]"
    echo >>../.gclient "target_os=['android']"

    git submodule foreach git config -f ./.git/config submodule.$name.ignore all
    git config --add remote.origin.fetch '+refs/tags/*:refs/tags/*'
    #git config diff.ignoreSubmodules all

    echo -e ${RED} -------- sync third_party repos ${NC}
    gclient sync -D --no-history --nohooks

    git config user.email "you@example.com"
    git config user.name "Your Name"

    # remove origin for chromium
    # git remote remove origin

    echo -e ${RED} -------- running install-build-deps-android ${NC}
    sudo build/install-build-deps-android.sh

    echo -e ${RED} -------- running hooks ${NC}
    gclient runhooks

    echo -e ${RED} -------- packing chromium dir ${NC}
    cd ../..
    tar -czf chromium.$VERSION.tar.gz ./chromium

    echo -e ${RED} -------- uploading to storage ${NC}
    lftp $FTP_HOST -u $FTP_USER,$FTP_PWD -e "set ftp:ssl-force true; set ssl:verify-certificate false; cd /bromite; put chromium.$VERSION.tar.gz; quit"
else
    echo -e ${RED} -------- unpacking ${NC}
    tar xf chromium.$VERSION.tar.gz

    echo -e ${RED} -------- running install-build-deps-android ${NC}
    sudo chromium/src/build/install-build-deps-android.sh
fi

rm chromium.$VERSION.tar.gz

