#!/usr/bin/env bash

# Function to clean up when script exits
cleanup() {
    # Return from alternate screen
    tput rmcup
    # Show cursor
    tput cnorm
    # Reset terminal settings
    stty echo
}

# Set up trap to ensure cleanup happens even if script is interrupted
trap cleanup EXIT INT TERM

# Hide cursor
tput civis
# Save current screen and switch to alternate screen
tput smcup
# Enable character-by-character input mode
stty -echo

if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not inside a git repository."
    exit 1
fi

# Get list of changed files including those in nested directories
# Using a different approach to parse git status output
changed_files=$(git status -s | sed 's/^...//')

if [ -z "$changed_files" ]; then
    echo "No changed files to commit."
    exit 0
fi

# Clear screen before each major step
clear
echo "📂 Selecting files for commit... (type to search, Tab to select, Enter to confirm)"
selected_files=$(echo "$changed_files" | gum filter --no-limit --height 15 --placeholder "Search files...")

if [ -z "$selected_files" ]; then
    echo "No files selected. Exiting."
    exit 0
fi

# Add the selected files to staging
echo "$selected_files" | xargs git add

# Clear screen before commit type selection
clear
echo "🏷️ Select commit type:"
commit_type=$(echo -e "fix\nfeat\ndocs\nstyle\nrefactor\ntest\nchore\nrevert" | gum filter --height 10 --limit 1 --placeholder "Search commit types...")

# Clear screen before summary input
clear
echo "📝 Enter commit summary:"
commit_summary=$(gum input --placeholder "Summary of changes")

if [ -z "$commit_summary" ]; then
    echo "No commit message provided. Exiting."
    git reset HEAD
    exit 1
fi

# Clear screen before description input
clear
echo "📄 Enter detailed description (optional, press Ctrl+D when done):"
commit_description=$(gum write --placeholder "Detailed description of changes")

# Create the final commit message
if [ -z "$commit_description" ]; then
    commit_message="${commit_type}: ${commit_summary}"
else
    commit_message="${commit_type}: ${commit_summary}

${commit_description}"
fi

# Clear screen before showing final review
clear
echo "🔍 Review your commit:"
echo "------------------------------"
echo "Files to be committed:"
echo "$selected_files" | sed 's/^/- /'
echo "------------------------------"
echo -e "Commit message:\n$commit_message"
echo "------------------------------"

if gum confirm "Proceed with commit?"; then
    git commit -m "$commit_message"
    echo "✅ Commit successful!"
else
    git reset HEAD
    echo "❌ Commit cancelled."
fi

# Final paus
