set fish_greeting # Disable greeting
# Set up paths
# If you come from bash you might have to change your $PATH
set -x PATH $HOME/bin /usr/local/bin $PATH $HOME/.local/bin
set -gx PATH $HOME/.config/emacs/bin $PATH
set -gx PATH ~/.emacs.d/bin $PATH
# Set language and collation for proper terminal behavior
set -x LANG en_US.UTF-8
# Set C collation for sane technical results
set -x LC_COLLATE C


# Load zoxide for better directory navigation
zoxide init fish | source

# Aliases for better file listing with eza
alias ls='eza --icons'
alias lsa='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'
alias cls="clear"
alias vim="nvim"
alias rebuild="$HOME/helper.fish"
alias cd="z" # Use zoxide instead of cd
alias cat="bat"

abbr up  "nh os switch -u"
abbr nxd "nix develop"
abbr nxf "nix flake"
abbr nxs "nix-shell"
abbr gta "git add"
abbr gtc "git commit -m"
abbr gtp "git push"
abbr com "commit"



# Set up environment variables
set -x MANPAGER 'nvim +Man!'

# Set up fzf
fzf --fish | source

function open_aterm
    termsh
    commandline -f cancel
end

bind \cn open_aterm

# History settings
set -x HISTSIZE 10000
set -x SAVEHIST 10000

# Initialize starship prompt
starship init fish | source

set -U fish_color_command '#d3869b'
