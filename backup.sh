#!/usr/bin/env bash
set -euo pipefail

# ========================
# Prep - you can change where you want backups to go - ex: set this below
#       target="$HOME/some_other_folder"
# ========================
# How this works: 
# 1. go to whatever folder you want and run the backup command
# 2. it will create a zip file in your folder of choice based on the folder name you have and what you give it
# NOTE: -i means keep images. -r means write a note and timestamp to a backup log file
# NOTE: if the string is not given, the code will ask. it's used when saving the filename
#
# Install
#       1. place into your home folder and make executable: ex - run this command: chmod +x ~/backup.sh
#       2. edit the lines below to say where backups & logs should go and edit the excluded folders/files below.
#
# Usage: 
#    cd "some folder"
#    ~/backup.sh -i -r "this is a backup name"
#    # result:    ~/some_folder_this_is_a_backup_name.zip"
# ========================

# ========================
# target should end with '/'
target="$HOME/"
# set if you're gonna use backups notes. ex: log_file="$HOME/_DEPLOYMENTS_AND_BACKUPS.log"
log_file="$HOME/backup-runs.log"
log_title="Code Backed Up"
# add more folder names or extensions if desired
exclude_names=(node_modules .git .husky .next venv .vercel)
exclude_exts=(woff ttf pdf otf zip csv)
# use -i to keep or no -i to skip images
exclude_image_exts=(png jpeg jpg)
# other patterns
exclude_file_patterns=('.env*')
# ========================

record=false
include_images=false

while getopts ":ri" opt; do
  case "$opt" in
    r) record=true ;;
    i) include_images=true ;;
    *) exit 1 ;;
  esac
done

shift $((OPTIND - 1))

if [ "$#" -gt 0 ]; then
  desc="$*"
else
  read -r -p "Description: " desc
fi

desc="${desc:-manual}"
desc="${desc// /-}"

project_name="$(basename "$PWD")"
outfile="${target}${project_name}_${desc}.zip"

#=====================================================================
[ "$include_images" != true ] && exclude_exts+=("${exclude_image_exts[@]}")
#-------
excludes=()
for name in "${exclude_names[@]}"; do excludes+=("$name/*" "*/$name/*"); done
for pat in "${exclude_file_patterns[@]}"; do excludes+=("$pat" "*/$pat"); done
for ext in "${exclude_exts[@]}"; do excludes+=("*.$ext"); done
#-------
zip -r "$outfile" . -x "${excludes[@]}"
#=====================================================================

if [ "$record" = true ]; then
  echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') $log_title | $desc" >> "$log_file"
fi

echo "$(date) Created: $outfile"
