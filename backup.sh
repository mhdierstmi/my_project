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
get_backup_destination() {
  BACKUP_DEST=$1
  if [ -z "$BACKUP_DEST" ]; then
    echo "Error: Backup destination path not specified as argument."
    exit 1
  fi
  mkdir -p "$BACKUP_DEST"
  echo "Backup destination set to: $BACKUP_DEST"
  echo ""
}
exit 0
