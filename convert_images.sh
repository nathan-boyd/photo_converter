#!/bin/bash

set -eu -o pipefail

echo "  ___                               ____                          _            "
echo " |_ _|_ __ ___   __ _  __ _  ___   / ___|___  _ ____   _____ _ __| |_ ___ _ __ "
echo "  | || '_ \` _ \ / _\` |/ _\` |/ _ \ | |   / _ \| '_ \ \ / / _ \ '__| __/ _ \ '__|"
echo "  | || | | | | | (_| | (_| |  __/ | |__| (_) | | | \ V /  __/ |  | ||  __/ |   "
echo " |___|_| |_| |_|\__,_|\__, |\___|  \____\___/|_| |_|\_/ \___|_|   \__\___|_|   "
echo "                      |___/                                                    "
echo ""


if ! magick -version &> /dev/null
then
    echo "Magick photo converter binary could not be found."
    exit 1
fi

PHOTOS_DIR="$HOME/Pictures/Photos Library.photoslibrary/originals"

echo "How many days of photos would you like to convert?"
read -r FILE_AGE_DAYS

re='^[0-9]+$'
if ! [[ $FILE_AGE_DAYS =~ $re ]] ; then
   echo "error: '$FILE_AGE_DAYS' is not a number" >&2; exit 1
fi

SEARCH_DATE=$(date -j -v-"$FILE_AGE_DAYS"d '+%Y-%m-%d')
echo "Converting photos taken on or after $SEARCH_DATE"
echo ""

DESTINATION_DIR="${HOME}/Desktop/_converted_photos"

convert_photo () {

  to_convert="$0"
  modified_date=$(date -r "${to_convert}" '+%Y-%m-%d')
  destination_dir="$DESTINATION_DIR/${modified_date}"
  mkdir -p "${destination_dir}"

  new_file_name=$(basename -s ".heic" "${to_convert}")
  new_file_path="${destination_dir}/${new_file_name}".jpg

  if test -f "${new_file_path}"; then
      echo "image exists: skipping ${new_file_path}"
      exit 0
  fi

  echo "Converting image: ${to_convert}"

  magick convert "${to_convert}" "${new_file_path}"
}

export -f convert_photo

find "${PHOTOS_DIR}" -type f -newerBt "${SEARCH_DATE}" -name "*.heic" -exec bash -c "\
  export DESTINATION_DIR=$DESTINATION_DIR && \
  convert_photo ${0}" {} \;

echo ""
read -r -p "Done. Press any key to exit and open converted files directory."

open "$DESTINATION_DIR"
