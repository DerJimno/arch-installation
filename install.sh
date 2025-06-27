#!/bin/bash

DEVICE="/dev/sda"

# Check before proceeding
echo "About to partition $DEVICE. THIS WILL ERASE DATA. Continue? (y/N)"
read -r confirm
if [[ "$confirm" != "y" ]]; then
  echo "Aborted."
  exit 1
fi

# Use fdisk in a here-document
fdisk "$DEVICE" <<EOF
g
n
1

+550M
n
2


t
1
1
w 
EOF


