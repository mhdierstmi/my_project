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
list_files_to_backup() {
  TMP_FILE="file_list.txt"
  > "$TMP_FILE"
  while IFS='|' read -r path ext; do
    if [ -d "$path" ]; then
      echo "Searching files in $path with extension $ext"
      find "$path" -type f -name "*$ext" >> "$TMP_FILE"
    else
      echo "Warning: Path $path does not exist"
    fi
  done < backup.conf
  echo "Found files to backup:"
  cat "$TMP_FILE"
  echo ""
}
create_backup_archive() {
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  ARCHIVE_NAME="backup_$TIMESTAMP.tar.gz"
  ARCHIVE_PATH="$BACKUP_DEST/$ARCHIVE_NAME"
  if [ ! -s file_list.txt ]; then
    echo "No files to backup. Exiting."
    exit 1
  fi
  echo "Creating backup archive $ARCHIVE_PATH ..."
  tar -czf "$ARCHIVE_PATH" -T file_list.txt
  if [ $? -eq 0 ]; then
    echo "Backup archive created successfully."
  else
    echo "Error creating backup archive!"
    exit 1
  fi
  echo ""
}
log_backup() {
  LOG_FILE="backup.log"
  START_TIME=$1
  END_TIME=$2
  ARCHIVE_PATH=$3
  DURATION=$((END_TIME - START_TIME))
  FILE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
  echo "Backup completed at $(date)" >> "$LOG_FILE"
  echo "Backup file: $ARCHIVE_PATH" >> "$LOG_FILE"
  echo "File size: $FILE_SIZE" >> "$LOG_FILE"
  echo "Duration: ${DURATION}s" >> "$LOG_FILE"
  echo "---------------------------------" >> "$LOG_FILE"
  echo "Backup log updated:"
  tail -n 6 "$LOG_FILE"
  echo ""
}
cleanup_old_backups() {
  DAYS_TO_KEEP=7
  echo "Removing backup files older than $DAYS_TO_KEEP days from $BACKUP_DEST ..."
  find "$BACKUP_DEST" -type f -name "backup_*.tar.gz" -mtime +$DAYS_TO_KEEP -exec rm -v {} \;
  echo ""
}
get_backup_config
get_backup_destination "$1"
START_TIME=$(date +%s)
list_files_to_backup
create_backup_archive
END_TIME=$(date +%s)
log_backup $START_TIME $END_TIME "$ARCHIVE_PATH"
cleanup_old_backups
exit 0
