#!/bin/bash
echo "Backup script is now running"
get_backup_config() {
  echo "Step 1: Configure backup sources"
  read -p "Enter source directory path for backup: " src_dir
  if [ ! -d "$src_dir" ]; then
    echo "Error: Directory does not exist!"
    exit 1
  fi
exit 0
