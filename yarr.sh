playlist_url=$(gum input --placeholder "Enter playlist url...")
playlist_folder=$(gum input --placeholder "Enter playlist name...")

full_path="$HOME/Music/$playlist_folder"
prevpath=$(pwd)

mkdir -p "$full_path"
cd "$full_path" || exit

gum log -l info "Downloading playlist to $full_path"

yt-dlp_linux -f "bestaudio" --extract-audio --audio-quality 0 -o "%(title).80s.%(ext)s" "$playlist_url"

gum log -l info "Finished download"

cd "$prevpath"
