#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e ${RED} -------- chromium version is: $VERSION ${NC}

echo -e ${RED} -------- cloning depot_tools ${NC}
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

echo -e ${RED} -------- apply depot_tools patch ${NC}
cd depot_tools/
git apply ../depot_tools.diff
git apply ../remove_ninja_uploader.diff
cd ..

echo -e ${RED} -------- set envs ${NC}
PATH=/home/lg/working_dir/depot_tools:$PATH
echo $PATH

echo -e ${RED} -------- download chromium repo ${NC}
mkdir ./chromium
cd ./chromium

export DEPOT_TOOLS_UPDATE=0

gclient root

mkdir ./src
cd ./src

#CHR_SOURCE=https://chromium.googlesource.com/chromium/src.git
CHR_SOURCE=https://github.com/chromium/chromium.git

git init
git remote add origin $CHR_SOURCE

git fetch --depth 2 $CHR_SOURCE +refs/tags/$VERSION:chromium_$VERSION
git checkout $VERSION
VERSION_SHA=$( git show-ref -s $VERSION | head -n1 )

echo >../.gclient "solutions = ["
echo >>../.gclient "  { \"name\"        : 'src',"
echo >>../.gclient "    \"url\"         : '$CHR_SOURCE@$VERSION_SHA',"
echo >>../.gclient "    \"deps_file\"   : 'DEPS',"
echo >>../.gclient "    \"managed\"     : True,"
echo >>../.gclient "    \"custom_deps\" : {"
echo >>../.gclient "    },"
echo >>../.gclient "    \"custom_vars\": {"
echo >>../.gclient "       \"checkout_android_prebuilts_build_tools\": True,"
echo >>../.gclient "       \"checkout_telemetry_dependencies\": False,"
echo >>../.gclient "       \"codesearch\": 'Debug',"
echo >>../.gclient "    },"
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

echo -e ${RED} -------- running hooks ${NC}
gclient runhooks

echo -e ${RED} -------- download objdump ${NC}
tools/clang/scripts/update.py --package=objdump
