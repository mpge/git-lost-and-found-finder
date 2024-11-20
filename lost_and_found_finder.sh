#!/bin/bash

# Settings
output_file="lost_and_found_report.txt"
target_file="vue3/src/pages/billing/Payment.vue"

# Script
echo "Git Lost and Found Report for $target_file" > "$output_file"
echo "=========================================" >> "$output_file"

for dir in commit other; do
  if [ -d ".git/lost-found/$dir" ]; then
    echo "Processing $dir objects for $target_file..." | tee -a "$output_file"
    for file in .git/lost-found/$dir/*; do
      obj_hash=$(basename "$file")
      obj_type=$(git cat-file -t "$obj_hash")
      # Check if the object involves the target file
      if [[ "$obj_type" == "commit" ]]; then
        # Check if the commit contains changes to the target file
        git show --name-only "$obj_hash" | grep -q "$target_file"
        if [[ $? -eq 0 ]]; then
          echo "Commit: $obj_hash" | tee -a "$output_file"
          git show --no-patch --pretty="format:%h %ad" "$obj_hash" | tee -a "$output_file"
          echo "-------------------------" | tee -a "$output_file"
        fi
      elif [[ "$obj_type" == "blob" ]]; then
        # Check if the blob is part of the target file
        blob_path=$(git log --all --pretty=format:"%h %ad" --find-object="$obj_hash" --name-only | grep "$target_file")
        if [[ -n "$blob_path" ]]; then
          echo "Blob: $obj_hash (related to $target_file)" | tee -a "$output_file"
          echo "Blob content:" | tee -a "$output_file"
          git cat-file -p "$obj_hash" | tee -a "$output_file"
          echo "-------------------------" | tee -a "$output_file"
        fi
      fi
    done
  else
    echo "Directory .git/lost-found/$dir does not exist." | tee -a "$output_file"
  fi
done
