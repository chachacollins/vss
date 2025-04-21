#!/usr/bin/env fish

# ANSI Color Codes
set GREEN '\033[0;32m'
set RED '\033[0;31m'
set YELLOW '\033[1;33m'
set BLUE '\033[0;34m'
set NC '\033[0m' # No Color

# Function to print colored output
function print_color
    set color $argv[1]
    set message $argv[2]
    echo -e "$color$message$NC"
end

# Store the current directory
set ORIGINAL_DIR (pwd)

# Run NixOS switch command
print_color "$BLUE" "Switching NixOS configuration..."
set HASH (nh os switch | sha256sum | cut -d' ' -f1)

# Check the exit status of the previous command
if test $status -eq 0
    # Change to the snowflake directory
    print_color "$YELLOW" "Changing to ~/snowflake directory..."
    cd ~/snowflake
    
    # Perform git add and commit with the hash as the commit message
    print_color "$GREEN" "Staging changes..."
    git add .
    
    print_color "$GREEN" "Committing changes..."
    git commit -m "NixOS system update: $HASH"
    
    # Return to the original directory
    print_color "$YELLOW" "Returning to original directory..."
    cd "$ORIGINAL_DIR"
    
    print_color "$GREEN" "✔ NixOS system switched and changes in ~/snowflake committed successfully."
else
    # Return to the original directory even if the switch fails
    cd "$ORIGINAL_DIR"
    
    print_color "$RED" "✘ NixOS system switch failed. No changes committed."
    exit 1
end
