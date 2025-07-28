#!/bin/bash
echo "Backup script is now running"
get_backup_config() {
  echo "Step 1: Configure backup sources"
  read -p "Enter source directory path for backup: " src_dir
  if [ ! -d "$src_dir" ]; then
    echo "Error: Directory does not exist!"
    exit 1
  fi
  read -p "Enter file extensions to backup (comma separated, e.g. txt,sh,py): " ext_list
  > backup.conf
  IFS=',' read -ra exts <<< "$ext_list"
  for ext in "${exts[@]}"; do
    echo "$src_dir|.$ext" >> backup.conf
  done
  echo "backup.conf created with following content:"
  cat backup.conf
  echo ""
}
exit 0
