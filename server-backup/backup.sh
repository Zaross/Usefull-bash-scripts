#!/bin/bash

SCRIPTNAME=$(basename "$0")
DESTINATION="$1"

check_for_empty_input() {
  if [ -z "$DESTINATION" ]; then
    echo "Error: No backup destination provided."
    echo "Usage: $SCRIPTNAME <destination-path>"
    exit 1
  fi

  if [ ! -d "$DESTINATION" ]; then
    echo "Error: The specified destination '$DESTINATION' is not a valid directory."
    exit 1
  fi
}

main() {
  check_for_empty_input

  echo "Creating backup in the directory $DESTINATION..."

  tar -zcvpf "$DESTINATION"/full-backup-"$(date '+%d.%m.%Y')".tar.gz \
      --directory / --exclude=mnt --exclude=proc --exclude=var/spool/squid .

  echo "Backup completed successfully."
}

main "$@"

exit 0
