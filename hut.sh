#!/usr/bin/env bash
set -e  
documents="$HOME/Documents/"  
url=$(gum input --placeholder "url of website")
if [ -z "$url" ]; then
  echo "Error: No URL provided"
  exit 1
fi
gum spin --spinner dot --title "Downloading website" -- \
wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -P "$documents" "$url"

if [ $? -eq 0 ]; then
  gum log --structured --level info "Successfully saved website" name "$url"
else
  gum log --structured --level error "Failed to save website" name "$url"
fi
