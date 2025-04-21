#!/usr/bin/env bash
targets=$(cat Makefile | awk -F: '
  /^[^[:space:]].*:/ {              
    if ($0 !~ /^[^:]*:=[^:]*$/) {    
      print $1
    }
  }' | sort -u)
if [[ -z "$targets" ]]; then
  echo "No targets found in Makefile."
  exit 1
fi

selected=$(echo "$targets" | fzf \
  --prompt="Pick a make target: " \
  --preview="make -n {} " \
  --preview-window=up:wrap)
if [[ -z "$selected" ]]; then
  echo "No target selected. Exiting."
  exit 0
fi
echo -e "Running: make $selected"
make "$selected"
