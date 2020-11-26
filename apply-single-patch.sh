#!/bin/bash

PATCH=$1

if [ -z "$2" ]
then
	PATCH_NEW_PATH="/home/cab/bromite/build/patches-new"
else
	PATCH_NEW_PATH=$2
fi

dos2unix $PATCH

echo ""
echo "Applying patch $PATCH"
git apply --reject --whitespace=fix $PATCH

for file in $(find . -name *.rej); do
		echo " -> Check $file";
		wiggle --replace ${file::-4} $file && rm $file && rm ${file::-4}.porig && echo "    OK";
done

OK=1
for file in $(find . -name *.rej); do
	echo "---Found: $file";
	OK=0
done

if [[ OK -eq 0 ]]; then
	echo "Patch not apply cleanly. Please fix..."
	echo "Press return"
	read  -n 1

else
	echo "Patch apply cleanly."

fi

echo "  Deleting rej"
find . -type f -name '*.rej' -delete
find . -type f -name '*.porig' -delete

#echo "Read to add. Press return"
#read  -n 1

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

git reset --hard
git clean -f -d

echo "  Applying new patch"
git am $PATCH_FILE
