#!/bin/bash

VERSION=$(cat ~/bromite/build/RELEASE)
CURRENT_RELEASE=$(git -C ~/chromium/src/ rev-parse --verify refs/tags/$VERSION)


for file in $(git -C ~/chromium/src/ show --pretty="" --name-only $CURRENT_RELEASE...HEAD); do
   DIRNAME=$(dirname $file)
   mkdir -p ~/mytests/$DIRNAME
   git -C ~/chromium/src/ show $CURRENT_RELEASE:$file > ~/mytests/$file
done
git -C ~/mytests/ add .
git -C ~/mytests/ commit -m "$VERSION"


ALLPATCHS_E=$(git -C ~/chromium/src/ rev-list --reverse $CURRENT_RELEASE...HEAD)
for patch in $ALLPATCHS_E; do

    for file in $(git -C ~/chromium/src/ show --pretty="" --name-only $patch); do
        DIRNAME=$(dirname $file)
        mkdir -p ~/mytests/$DIRNAME
        #cp ~/chromium/src/$file ~/mytests/$file
        #echo $file
	OK=0
        git -C ~/chromium/src/ show $patch:$file > ~/mytests/$file && OK=1
	if [[ OK -eq 0 ]]; then
          echo "   Removing ~/mytests/$file"
          rm ~/mytests/$file
	fi
    done

#echo $ALLFILES_E
#read -n 1

    MESSAGE=$(git -C ~/chromium/src/ log --pretty=format:%s -n 1 $patch)
    git -C ~/mytests/ add .
    git -C ~/mytests/ commit -m "$MESSAGE"

#read -n 1
done

