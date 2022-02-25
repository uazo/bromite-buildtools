#!/bin/bash

VERSION=$(cat ~/bromite/build/RELEASE)
CURRENT_RELEASE=$(git -C ~/chromium/src/ rev-parse --verify refs/tags/$VERSION)

ALLPATCHS_E=$(git -C ~/chromium/src/ rev-list HEAD...$CURRENT_RELEASE)

mkdir ~/bromite/build/patches-new
rm ~/bromite/build/patches-new/patch-list

NO_NAME=1

for patch in $ALLPATCHS_E; do

	PATCH_FILE=$(git -C ~/chromium/src/ show -s $patch | grep FILE: | sed 's/FILE://g' | sed 's/^[ \t]*//;s/[ \t]*$//')
	if [[ "$PATCH_FILE" == *"Automated-domain-substitution"* ]]; then
		continue
	fi

	echo $PATCH_FILE >>~/bromite/build/patches-new/patch-list

done

tac ~/bromite/build/patches-new/patch-list >~/bromite/build/patches-new/zz-patch-list.txt
rm ~/bromite/build/patches-new/patch-list
