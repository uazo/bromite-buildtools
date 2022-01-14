#!/bin/bash

PATCH=$1
LOG_FILE=~/build.log

dos2unix $PATCH

OK=0
DOBUILD=1
DOEXPORT=1

TEST=0
git log | grep FILE:$(basename -- $PATCH) && TEST=1
if [[ TEST -eq 1 ]]; then

        echo "Patch $PATCH already exists. skipped." | tee -a ${LOG_FILE}
        exit 0

fi

echo "" | tee -a ${LOG_FILE}
echo "Applying patch $PATCH" | tee -a ${LOG_FILE}
git apply --reject --whitespace=fix $PATCH && OK=1

if [[ OK -eq 0 ]]; then
        OK=1
        for file in $(grep '+++ b/' $PATCH | sed -e 's#+++ [ab]/##'); do
                test -f $file || OK=0
        done

        for file in $(find . -name *.rej); do
                echo " -> Check $file" | tee -a ${LOG_FILE};
                wiggle --no-ignore --replace ${file::-4} $file && rm $file && rm ${file::-4}.porig && echo "    OK" || OK=0
        done

        for file in $(find . -name *.rej); do
                echo "    Found: $file" | tee -a ${LOG_FILE};
                git add ${file::-4}
                OK=0
        done

        if [[ OK -eq 0 ]]; then
                DOBUILD=1
                echo "Current patch $PATCH" | tee -a ${LOG_FILE}
                echo "   Patch not apply cleanly. Please fix..." | tee -a ${LOG_FILE}
                if [ -n "$SILENT" ]; then
                   exit 1
                fi
                echo "   Press return"
                read  -n 1
        else
                echo "   Patch not apply cleanly. Wiggle done!" | tee -a ${LOG_FILE}
        fi

        echo "   Deleting rej"
        find . -type f -name '*.rej' -delete
        find . -type f -name '*.porig' -delete

else
        echo "Patch apply cleanly." | tee -a ${LOG_FILE}
        DOBUILD=0
fi

if [[ DOBUILD -eq 1 ]]; then
        OK=0
        #echo "Building ${PATCH}: chrome_public_apk" | tee -a ${LOG_FILE}
        #date "+%Y%m%d %H.%M.%S" | tee -a ${LOG_FILE}
        #autoninja -C out/arm64 chrome_public_apk && OK=1
        #date "+%Y%m%d %H.%M.%S" | tee -a ${LOG_FILE}

        DOEXPORT=1

fi

if [[ OK -eq 0 ]]; then
        if [ -z "$SILENT" ]; then
           echo "Read to add $PATCH. Press return"
           read  -n 1
        fi
fi

if [[ DOEXPORT -eq 1 ]]; then
       until false
       do
           bash ~/bromite-buildtools/create-from-patch.sh $PATCH $2 || exit 1

           rm /tmp/1 /tmp/2 || true
           lsdiff $PATCH >/tmp/1
           lsdiff ../../bromite/build/patches-new/$(basename -- $PATCH) >/tmp/2
           STATUS="$(cmp --silent /tmp/1 /tmp/2; echo $?)"
           if [[ $STATUS -ne 0 ]]; then
                  git reset HEAD^
                  diff /tmp/1 /tmp/2
                  echo "Some files are missing. Check again." | tee -a ${LOG_FILE}
                  if [ -n "$SILENT" ]; then
                     exit 1
                  fi

                  read -r -p "y to continue [y/N] " response
                  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                       bash ~/bromite-buildtools/create-from-patch.sh $PATCH $2 || exit 1
                       break
                  fi
           else
              break
           fi
        done
fi
