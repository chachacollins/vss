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

# Automatically add deleted files to staging
echo "Auto-adding deleted files to staging..."
git ls-files --deleted | xargs -r git rm

# Get remaining files that need manual selection
changed_files=$(git status -s | grep -v "^D" | sed 's/^...//')

if [ -z "$changed_files" ]; then
    echo "No additional files to commit."
    echo "Only deleted files will be committed."
else
    # Clear screen before each major step
    clear
    echo "📂 Selecting files for commit... (type to search, Tab to select, Enter to confirm)"
    selected_files=$(echo "$changed_files" | gum filter --no-limit --height 15 --placeholder "Search files...")

    if [ -z "$selected_files" ]; then
        echo "No additional files selected."
    else
        # Add the selected files to staging
        echo "$selected_files" | xargs git add
    fi
fi

# Check if there are any staged changes
if [ -z "$(git diff --cached --name-only)" ]; then
    echo "No files staged for commit. Exiting."
    exit 0
fi

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
git diff --cached --name-status | sed 's/^A/➕ Added:     /; s/^M/🔄 Modified:  /; s/^D/❌ Deleted:   /; s/^R/🔄 Renamed:   /; s/^C/📋 Copied:    /'
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

# Final pause to see the result before returning to normal screen
sleep 1.5
