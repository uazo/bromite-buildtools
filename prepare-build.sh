#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

#cd ~

sudo apt-get install python
sudo apt-get install wiggle

echo -e ${RED} -------- download bromite repo ${NC}
git clone https://github.com/bromite/bromite
cd bromite
git fetch
git pull

VERSION=$( cat ./build/RELEASE )
echo -e ${RED} -------- lastest version is: $VERSION ${NC}

cd ..
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
PATH=./chromium/src/third_party/llvm-build/Release+Asserts/bin:./depot_tools/:/usr/local/go/bin:$PATH

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

#echo -e ${RED} -------- sync other chromium repos ${NC}

#gclient metrics --opt-out
git submodule foreach git config -f ./.git/config submodule.$name.ignore all
git config --add remote.origin.fetch '+refs/tags/*:refs/tags/*'
#git config diff.ignoreSubmodules all

gclient sync -D --no-history --nohooks --output-json=gclient-sync.log

git config user.email "you@example.com"
git config user.name "Your Name"

# remove origin for chromium
git remote remove origin
