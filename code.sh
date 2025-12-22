apps=(

  'zed' # code editor.
  'git' # version control.
  'jq'  # JSON processor.

  'bash'  # shell.
  'shfmt' # shell formatter.

  'nodejs' # js runtime.
  'pnpm'   # js package manager.'

  'go'      # golang
  'gopls'   # golang lsp
  'gofumpt' # golang formatter

)

for app in "${apps[@]}"; do
  sudo pacman -S "$app" --noconfirm --needed
done

mkdir -p ~/Batcave
git config --global user.email "commitsovercoffee@gmail.com"
git config --global user.name "commitsovercoffee"

cowsay "eat. sleep. code. repeat."
