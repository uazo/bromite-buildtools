#!/bin/bash

git am --abort

PATCH_OLD_PATH=~/bromite/build/patches
PATCH_NEW_PATH=~/bromite/build/patches-new

DESTINATION=~/bromite/build/bromite_patches_list_ok.txt
DESTINATION_FAILED=~/bromite/build/bromite_patches_list_failed.txt

rm $DESTINATION
rm $DESTINATION_FAILED
mkdir $PATCH_NEW_PATH

IFS=$'\n'

PATCH_LIST=~/bromite/build/bromite_patches_list_new.txt
if [ ! -f $PATCH_LIST ]; then
	cp ~/bromite/build/bromite_patches_list.txt $PATCH_LIST
fi

echo "Phase 1: check clean"
for current_file in $(cat $PATCH_LIST); do

    if [[ $current_file =~ ^#.* ]]; then

        echo "Executing $current_file"
        eval "${current_file:1}"
        echo $current_file >>$DESTINATION

    elif [[ $current_file =~ ^-.* ]]; then

        echo "Skipping $current_file"

    elif [[ $current_file =~ ^=.* ]]; then

        echo "Adding $current_file"
        echo "Executing bash ~/create-from-patch.sh $PATCH_OLD_PATH/${current_file:1} $PATCH_NEW_PATH"

        bash ~/bromite-buildtools/create-from-patch.sh $PATCH_OLD_PATH/${current_file:1} $PATCH_NEW_PATH

       #echo "Press return"
       #read  -n 1


    elif [[ $current_file =~ ^1.* ]]; then

        echo "Using new path $current_file"

        bash ~/bromite-buildtools/apply-single-patch.sh $PATCH_NEW_PATH/${current_file:1} $PATCH_NEW_PATH

        echo ""
        LAST_COMMIT=$(git rev-parse HEAD)
        echo "Last Commit " $LAST_COMMIT
        bash ~/bromite-buildtools/export-single-patch.sh $LAST_COMMIT

    else

        bash ~/bromite-buildtools/apply-single-patch.sh $PATCH_OLD_PATH/$current_file $PATCH_NEW_PATH

        echo $current_file >>$DESTINATION
        echo $PATCH_FILE

        echo ""
        LAST_COMMIT=$(git rev-parse HEAD)
        echo "Last Commit " $LAST_COMMIT
        bash ~/bromite-buildtools/export-single-patch.sh $LAST_COMMIT

        #cp -r ~/bromite/build/patches-new/* ~/br2/bromite/build/patches/
        #git -C ~/br2/bromite/ add .
        #git -C ~/br2/bromite/ commit -m "$current_file"

    fi

done
