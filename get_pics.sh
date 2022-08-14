#!/bin/bash

set -eu -o pipefail

if ! magick -version &> /dev/null
then
    echo "magick photo converter could not be found"
    exit
fi

FILE_AGE_DAYS=7
echo "How many days of photos would you like to convert? ($FILE_AGE_DAYS)"?
read -r FILE_AGE_DAYS

re='^[0-9]+$'
if ! [[ $FILE_AGE_DAYS =~ $re ]] ; then
   echo "error: '$FILE_AGE_DAYS' is not a number" >&2; exit 1
fi

SEARCH_DATE=$(date -j -v-"$FILE_AGE_DAYS"d)
echo "converting photos since $SEARCH_DATE"

PHOTOS_DIR="$HOME/Pictures/Photos Library.photoslibrary/originals"
echo ""

DESTINATION_DIR="${HOME}/Desktop/_converted_photos"

convert_photo () {

  to_convert="$0"
  modified_date=$(date -r "${to_convert}" '+%Y-%m-%d')
  destination_dir="$DESTINATION_DIR/${modified_date}"
  mkdir -p "${destination_dir}"

  new_file=$(basename -s ".heic" "${to_convert}")
  new_path="${destination_dir}/${new_file}".jpg

  if test -f "${new_path}"; then
      echo "${new_path} exists. skipping."
      exit
  fi

  echo "converting ${to_convert}"

  magick convert "${to_convert}" "${new_path}"
}

export -f convert_photo

find "${PHOTOS_DIR}" -type f -newerBt "${SEARCH_DATE}" -name "*.heic" -exec bash -c "\
  export DESTINATION_DIR=$DESTINATION_DIR && \
  convert_photo ${0}" {} \;

read -r -p "Done press any key to exit"

open "$DESTINATION_DIR"
