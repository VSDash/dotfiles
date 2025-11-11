# dotfiles

My personal dotfiles for macOS/Linux development environments. Includes shell configurations, Git settings, development tools, and automated setup scripts.

## 🚀 Quick Start

### New Machine Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the installation script
chmod +x install.sh
./install.sh
```

The install script will:
- Install Homebrew (macOS/Linux)
- Install packages from Brewfile (OS-aware: skips GUI apps on Linux)
- Create symlinks to dotfiles
- Set up shell configurations
- Set up mise with global tools
- Apply macOS defaults (macOS only)

**Note:** The script is cross-platform compatible and handles errors gracefully. On Linux, it will skip macOS-specific GUI applications (casks) automatically.

### Coder.com Integration

These dotfiles are designed to work automatically with [Coder](https://coder.com) workspaces:

```hcl
# In your Coder template.tf
module "dotfiles" {
  source   = "registry.coder.com/modules/dotfiles/coder"
  version  = "1.0.14"
  agent_id = coder_agent.main.id
}
```

**Coder-specific behavior:**
- Installation is fully automated (no user input required)
- mise activation and global tool installation happens automatically
- Symlinks are created in `~/.config/coderv2/dotfiles/`
- New terminals automatically have Node.js, pnpm, and all tools available
- No shell restart needed - tools are activated during workspace creation

### Manual Bootstrap (Symlink Only)

If you already have tools installed and just want to symlink dotfiles:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## 📁 What's Included

### Shell Configuration
- `.zshrc` - Zsh configuration with aliases, functions, and prompt
- `.bashrc` - Bash configuration (similar to zshrc)
- `.bash_profile` - Bash login shell config

### Git Configuration
- `.gitconfig` - Git aliases, colors, and settings
- `.gitignore_global` - Global gitignore patterns

### Package Management
- `homebrew/Brewfile` - Homebrew packages and cask applications

### System Configuration
- `macos/defaults.sh` - macOS system preferences and tweaks

### Scripts
- `install.sh` - Full installation script for new machines
- `bootstrap.sh` - Symlink manager with backup functionality

## 🔧 Customization

### mise Configuration

The global mise config is at `.config/mise/config.toml` and will be symlinked to `~/.config/mise/config.toml`. This sets:
- Default Node.js version (lts)
- Global pnpm (latest)
- Editor preferences
- Node.js memory limits

Edit this file to change global defaults.

### Shell Configuration

The shell configs include:
- **Aliases** for common commands (git, docker, npm, etc.)
- **Functions** for utilities (mkcd, extract, etc.)
- **Prompt** with git branch integration
- **History** optimization
- **Path** configuration for Homebrew, pnpm, nvm

Edit `~/.zshrc.local` or `~/.bashrc.local` for machine-specific settings that won't be tracked.

### Git Configuration

Update your Git user info in `.gitconfig`:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Or edit `.gitconfig` directly before running bootstrap.

### Brewfile

Edit `homebrew/Brewfile` to add/remove packages:

```ruby
# Add a formula
brew "package-name"

# Add a cask (application)
cask "application-name"

# Install/update packages
brew bundle --file=~/dotfiles/homebrew/Brewfile
```

### macOS Defaults

The `macos/defaults.sh` script sets various system preferences:
- Finder settings (show hidden files, extensions, path bar)
- Dock configuration (size, auto-hide, animations)
- Trackpad and keyboard settings
- Screenshot preferences
- Safari/WebKit settings

Review and customize before running.

## � mise - Modern Development Environment Manager

This dotfiles setup includes **[mise](https://mise.jdx.dev/)**, a powerful all-in-one tool that replaces:
- **nvm/asdf** - Version management for Node.js, Python, Go, Rust, etc.
- **direnv** - Automatic environment variables per project
- **make** - Task runner for project workflows

### Why mise for Node.js Developers?

✅ **No more nvm/asdf complexity** - One tool for all runtimes  
✅ **Automatic version switching** - Enter a project directory, get the right Node version  
✅ **Project isolation** - Each project has its own tool versions and env vars  
✅ **Fast** - Written in Rust, no shims, direct path manipulation  
✅ **Task runner built-in** - Replace common npm scripts with mise tasks  

### Quick mise Usage

```bash
# Install Node.js LTS globally
mise use -g node@lts

# Set Node.js version for current project
cd my-project
mise use node@22

# Install tools from mise.toml
mise install

# Run project tasks
mise run dev
mise run build
mise run test

# List available versions
mise list node
mise list pnpm

# Execute command with specific version
mise exec node@18 -- node app.js
```

### Project Configuration

Create a `mise.toml` in your project root (see `mise.toml.example` for full example):

```toml
[tools]
node = "22"
pnpm = "9"

[env]
NODE_ENV = "development"
API_URL = "http://localhost:3000"

[tasks.dev]
run = "pnpm run dev"

[tasks.build]
run = "pnpm run build"
```

Now `cd` into the project and mise automatically:
- Activates Node.js 22
- Installs pnpm 9
- Sets environment variables
- Enables `mise run dev` and `mise run build`

## �📦 Key Features

### Shell Aliases

**Navigation:**
```bash
..          # cd ..
...         # cd ../..
~           # cd ~
```

**Git shortcuts:**
```bash
g           # git
gs          # git status
ga          # git add
gc          # git commit
gp          # git push
gl          # git pull
glog        # git log --oneline --graph
```

**Development:**
```bash
c.          # code .
pi          # pnpm install
pr          # pnpm run
ni          # npm install
nr          # npm run
```

**mise shortcuts:**
```bash
mi          # mise install
mu          # mise use
ml          # mise list
mx          # mise exec
mr          # mise run
mt          # mise task run
mw          # mise watch
```

### Shell Functions

```bash
mkcd <dir>              # Create directory and cd into it
gcm "message"           # Git commit with message
extract <file>          # Extract any archive type
qfind <pattern>         # Quick find files
```

### Git Aliases

```bash
git s                   # status -s
git lg                  # pretty log graph
git cob <branch>        # checkout -b
git undo                # undo last commit (keep changes)
git cleanup             # remove merged branches
```

## 🔄 Updating

### Update Dotfiles

```bash
cd ~/dotfiles
git pull
./bootstrap.sh  # Re-symlink if needed
```

### Update Packages

```bash
# Update Homebrew packages
brew update && brew upgrade

# Or reinstall from Brewfile
brew bundle --file=~/dotfiles/homebrew/Brewfile
```

## 🗂 Directory Structure

```
dotfiles/
├── README.md                    # This file
├── install.sh                  # Full installation script
├── bootstrap.sh                # Symlink management script
├── .gitconfig                 # Git configuration
├── .gitignore_global          # Global gitignore
├── .zshrc                     # Zsh configuration (with mise integration)
├── .bashrc                    # Bash configuration (with mise integration)
├── .bash_profile              # Bash login configuration
├── MISE_GUIDE.md              # Comprehensive mise reference
├── mise.toml.example          # Example project mise configuration
├── mise-config.toml.example   # Example global mise configuration
├── .config/
│   └── mise/
│       └── config.toml        # Actual global mise config (symlinked)
├── homebrew/
│   └── Brewfile               # Package management (includes mise)
└── macos/
    └── defaults.sh            # macOS system preferences
```

## 🛡 Backup & Safety

The `bootstrap.sh` script automatically:
- Backs up existing files before symlinking
- Creates timestamped backup directory: `~/.dotfiles_backup_YYYYMMDD_HHMMSS`
- Skips files that don't exist in the repo
- Removes backup directory if empty

## 💡 mise Tips & Tricks

### Migrating from nvm

```bash
# If you have nvm installed, check your current version
nvm current

# Install it with mise
mise use -g node@$(nvm current)

# Uninstall nvm (optional)
rm -rf ~/.nvm
# Remove nvm lines from your old shell config
```

### Common mise Workflows

```bash
# Show all installed tools
mise list

# Update all tools to latest versions
mise upgrade

# Show current environment
mise env

# Run command with specific tool version
mise exec python@3.11 -- python script.py

# Watch for file changes and rerun task
mise watch -t test

# Show mise configuration
mise config

# Doctor - check mise setup
mise doctor

# Global tasks (available anywhere)
mise run update        # Update mise and all tools
mise run doctor        # Health check
mise run cleanup       # Clean cache
mise run versions      # Show installed versions
mise run outdated      # Check for updates
```

### Global Tool Configuration

Edit `~/.config/mise/config.toml` for global defaults:

```toml
[tools]
node = "lts"
pnpm = "latest"

[env]
NODE_OPTIONS = "--max-old-space-size=8192"

[tasks.update]
run = "mise self-update && mise plugins update && mise upgrade"
```

### Environment-Specific Configurations

Create environment-specific configs for different workflows:

```bash
# Development
export MISE_ENV=dev
mise install  # Loads mise.dev.toml

# Production
export MISE_ENV=prod
mise install  # Loads mise.prod.toml
```

### Auto-install on Directory Change

The dotfiles include a shell hook that automatically installs missing tools when you `cd` into a project directory with a `mise.toml` file. No manual `mise install` needed!

### File-based Tasks

Alternative to TOML tasks - create executable scripts:

```bash
# Create mise-tasks directory
mkdir -p mise-tasks

# Create a task
cat > mise-tasks/build << 'EOF'
#!/usr/bin/env bash
#MISE description="Build the project"
pnpm run build
EOF

chmod +x mise-tasks/build

# Run it
mise run build
```

See `mise-tasks-examples/` in this repo for more examples.

### Advanced: Multiple Tool Versions

Test across multiple Node versions:

```toml
[tools]
node = ["20", "22"]  # Installs both versions

[tasks.test-all]
run = """
mise exec node@20 -- npm test
mise exec node@22 -- npm test
"""
```

### Troubleshooting

#### Common Installation Warnings (Safe to Ignore)

**Homebrew on Linux:**
- `Tapping homebrew/bundle has failed` - This tap is deprecated and empty (safe to ignore)
- `Tapping homebrew/cask has failed` - Not needed anymore (safe to ignore)  
- `Tapping homebrew/core has failed` - Not needed anymore (safe to ignore)

These are expected warnings on modern Homebrew installations where these taps are now built-in.

**mise Configuration:**
- If you see "Config files are not trusted" errors, the install script handles this automatically
- Symlinked configs (like in Coder) require trusting both the symlink and target directories
- Run `mise trust ~/.config/mise` if issues persist

**Shell Changes:**
- `chsh` may require password authentication in non-interactive environments (like Coder)
- You can manually change shells later with: `chsh -s $(which zsh)`

#### mise Debugging

```bash
# Check mise health
mise doctor

# Clear cache if things are stale
mise cache clear

# Verbose mode for debugging
mise -v install node@22

# Check what config files are loaded
mise config

# See exact PATH modifications
mise env | grep PATH
```

## 🎯 Requirements

- macOS 10.15+ or Linux
- Bash or Zsh shell
- Git (will be installed if not present)
- Internet connection for Homebrew and packages
- mise (installed via Homebrew)

## 📝 Notes

- Shell configurations include a `.local` file pattern (`.zshrc.local`, `.bashrc.local`) for machine-specific settings
- These local files are not tracked in Git
- Symlinks point to the dotfiles repo, so git pull updates take effect immediately
- Some macOS settings require logout/restart to take effect

## 🤝 Contributing

Feel free to fork and customize for your own use! This is a personal dotfiles repo, but suggestions are welcome.

## 📄 License

MIT License - Feel free to use and modify as needed.

## 🔗 Useful Resources

- [mise Documentation](https://mise.jdx.dev/)
- [mise Registry](https://mise.jdx.dev/registry.html) - 100+ supported tools
- [GitHub Dotfiles Guide](https://dotfiles.github.io/)
- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)
- [Homebrew](https://brew.sh/)
