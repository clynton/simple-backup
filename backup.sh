#!/usr/bin/env bash
set -euo pipefail

# ========================
# Prep - you can change where you want backups to go - ex: set this below
#       target="$HOME/some_other_folder"
# ========================
# How this works: 
# 1. go to whatever folder you want and run the backup command
# 2. it will create a zip file in your folder of choice based on the folder name you have and what you give it
# 3. -i means keep images. -r means write a note and timestamp to a backup log file
#
# Usage: 
#    cd "some folder"
#    ~/backup.sh -i -r "This is a backup name"
#    # result:    ~/some_folder_This_is_a_backup_name"
# ========================

# ========================
target="$HOME/"
log_file="$HOME/backup-runs.log"
log_title="Code Backed Up"
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
outfile="${target}_${project_name}_${desc}.zip"


if [ "$include_images" = true ]; then
  zip -r "$outfile" . -x "*/node_modules/*" "*/.git/*" "*/.husky/*" "*/.next/*" ".env*" "*.woff" "*.ttf" "*.pdf" "*.otf" "*.zip" "*/venv/*" "*.csv"
else
  zip -r "$outfile" . -x "*/node_modules/*" "*/.git/*" "*/.husky/*" "*/.next/*" ".env*" "*.woff" "*.ttf" "*.pdf" "*.otf" "*.zip" "*/venv/*" "*.csv" "*.png" "*.jpeg"
fi


if [ "$record" = true ]; then
  echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') $log_title | $desc" >> "$log_file"
fi

echo "$(date) Created: $outfile"
