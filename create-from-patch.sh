#!/bin/bash

PATCH=$1

PLEASEWAIT=0
if [[ $PATCH =~ ^+.* ]]; then
	PLEASEWAIT=1
	PATCH=${PATCH:1}
fi

if [ -z "$2" ]
then
	PATCH_NEW_PATH="~/bromite/build/patches-new"
else
	PATCH_NEW_PATH=$2
fi

echo "  Creating new patch"
git add .

HEAD=$(sed -n '1,/---/ p' $PATCH | sed '/^---/d')
CONTENT=$(git -C ~/chromium/src/ diff --cached --binary)

PATCH_FILE=$PATCH_NEW_PATH/$(basename $PATCH)
rm $PATCH_FILE
echo "$HEAD" >$PATCH_FILE

NEWLINE=$(tail -n 1 "$PATCH_FILE")
echo $NEWLINE
if [[ "$NEWLINE" == Subject:* ]]; then
	echo "" >>$PATCH_FILE
else
	NEWLINE=$(tail -n 2 "$PATCH_FILE" | head -n 1)
	if [[ "$NEWLINE" == Subject:* ]]; then
		echo "" >>$PATCH_FILE
	fi
fi				

echo "FILE:$(basename $PATCH)" >>$PATCH_FILE
echo "---" >>$PATCH_FILE
echo "$CONTENT" >>$PATCH_FILE

#echo press return
#read  -n 1

git reset --hard
git clean -f -d

echo "  Applying new patch"
git am $PATCH_FILE
