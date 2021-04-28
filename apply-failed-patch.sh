#!/bin/bash

git am --abort

PATCH_OLD_PATH=../../bromite/build/patches
PATCH_NEW_PATH=../../bromite/build/patches-new
DESTINATION_FAILED=~/bromite/build/bromite_patches_list_failed.txt

mkdir $PATCH_NEW_PATH

IFS=$'\n'

for file in $(cat $DESTINATION_FAILED | sed -e 's/\r//g'); do

	if [[ $file =~ ^#.* ]]; then

		echo "Executing $file"
		eval "${file:1}"

	else

		PATCH=$PATCH_OLD_PATH/$file

		echo "Applying patch $PATCH"
		git apply --reject "$PATCH"

		for file in $(find . -name *.rej); do
			echo " -> Check $file";
			wiggle --replace ${file::-4} $file && rm $file && rm ${file::-4}.porig && echo "    OK";
		done

		for file in $(find . -name *.rej); do
			echo "---Found: $file"; 
		done

		read -p "--- ERROR: Press enter to continue"

		find . -type f -name '*.rej' -delete
		find . -type f -name '*.porig' -delete
		git add .

		HEAD=$(sed -n '1,/---/ p' $PATCH | sed '/^---/d')
		CONTENT=$(git -C ~/chromium/src/ diff --cached)

		PATCH_FILE=$PATCH_NEW_PATH/$(basename $PATCH)
		rm $PATCH_FILE
		echo "$HEAD" >$PATCH_FILE
		echo "" >>$PATCH_FILE
		echo "FILE:$(basename $PATCH)" >>$PATCH_FILE
		echo "---" >>$PATCH_FILE
		echo "$CONTENT" >>$PATCH_FILE

		sed -i '/^index/d' $PATCH_FILE
		sed -i '/^ mode change/d' $PATCH_FILE
		sed -i '/^old mode /d' $PATCH_FILE
		sed -i '/^new mode /d' $PATCH_FILE
		sed -i '/^create mode /d' $PATCH_FILE
		git reset --hard

		git am $PATCH_FILE
	fi

	#read -p "Press enter to continue"

done


