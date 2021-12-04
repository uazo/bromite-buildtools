#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

sudo apt install sed

cd chromium/src

echo -e ${RED} ------- apply patchs ${NC}
for file in $(cat ../../bromite/build/bromite_patches_list.txt) ; do

	if [[ "$file" == *"Automated-domain-substitution"* ]]; then
		echo -e ${RED} " -> Excluding $file" ${NC}
		continue
	fi
	
	echo -e ${RED} " -> Apply $file" ${NC}

	REPL="0,/^---/s//FILE:"$file"\n---/"
	cat ../../bromite/build/patches/$file | sed $REPL | git am

	if [ $? -ne 0 ]
	then
            echo -e "Error on ../../bromite/build/patches/${file}"
            exit 1
	fi

	echo " "
done
