#!/bin/bash

git am --abort

PATCH_OLD_PATH=../../bromite/build/patches
PATCH_NEW_PATH=../../bromite/build/patches-new
DESTINATION=~/bromite/build/bromite_patches_list_ok.txt
DESTINATION_FAILED=~/bromite/build/bromite_patches_list_failed.txt

rm $DESTINATION
rm $DESTINATION_FAILED
mkdir $PATCH_NEW_PATH

IFS=$'\n'

#cp ~/bromite/build/bromite_patches_list.txt ~/bromite/build/bromite_patches_list_new.txt

echo "Phase 1: check clean"
for current_file in $(cat ~/bromite/build/bromite_patches_list_new.txt); do

        if [[ $current_file =~ ^#.* ]]; then

                echo "Executing $current_file"
                eval "${current_file:1}"
				echo $current_file >>$DESTINATION

        else

				bash /home/cab/apply-single-patch.sh $PATCH_OLD_PATH/$current_file $PATCH_NEW_PATH
				
				echo $PATCH_FILE
				
				echo ""
				LAST_COMMIT=$(git rev-parse HEAD)
				echo "Last Commit " $LAST_COMMIT
				bash /home/cab/export-single-patch.sh $LAST_COMMIT

		fi

done
