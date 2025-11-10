# mise Quick Reference for Node.js Developers

## Installation & Setup

```bash
# Install via Homebrew (already in Brewfile)
brew install mise

# Add to shell (already in .zshrc/.bashrc)
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
echo 'eval "$(mise activate bash)"' >> ~/.bashrc

# Verify installation
mise --version
```

## Version Management

### Global Versions (System-wide)

```bash
# Install and use Node.js LTS globally
mise use -g node@lts

# Install specific version globally
mise use -g node@22
mise use -g pnpm@latest

# List globally installed tools
mise list -g
```

### Project Versions (Per Directory)

```bash
# In your project directory
cd my-project

# Use Node.js 20 for this project
mise use node@20

# Creates/updates mise.toml with:
# [tools]
# node = "20"

# Install all tools from mise.toml
mise install

# Auto-installs missing tools when entering directory
cd my-project  # mise detects mise.toml and auto-installs
```

### Version Syntax

```bash
node@22         # Latest 22.x.x
node@22.1       # Latest 22.1.x
node@22.1.0     # Exact version
node@lts        # Latest LTS
node@latest     # Latest stable
node            # Latest (same as latest)
```

## Checking Versions

```bash
# List all available Node.js versions
mise list-remote node

# Show installed versions
mise list node

# Show current active versions
mise current

# Check what's in use for this directory
mise which node
mise where node
```

## Environment Variables

### Project-specific Environment

```toml
# mise.toml
[env]
NODE_ENV = "development"
DATABASE_URL = "postgresql://localhost/mydb"
API_KEY = "dev-key-123"
```

### Load .env files

```toml
# mise.toml
_.file = ".env"
_.file = ".env.local"
```

### Show current environment

```bash
# Show all env vars mise would set
mise env

# Export to eval
eval "$(mise env)"
```

## Task Runner

### Define Tasks

```toml
# mise.toml
[tasks.dev]
description = "Start dev server"
run = "pnpm run dev"

[tasks.build]
run = "pnpm run build"

[tasks.test]
run = """
pnpm run lint
pnpm run test
"""

[tasks.deploy]
depends = ["test", "build"]
run = "npm run deploy"
```

### Run Tasks

```bash
# Run a task
mise run dev
mise run build

# List available tasks
mise tasks

# Run task with arguments
mise run test -- --watch

# Run multiple tasks
mise run lint test build
```

## Common Workflows

### New Project Setup

```bash
# Create new project
mkdir my-app && cd my-app

# Set Node.js version
mise use node@22 pnpm@9

# Creates mise.toml:
# [tools]
# node = "22"
# pnpm = "9"

# Install dependencies
pnpm init
pnpm install express
```

### Existing Project Migration

```bash
# If project has .nvmrc
cd existing-project
cat .nvmrc  # Shows: 20.11.0

# Set same version with mise
mise use node@20.11.0

# Can now remove .nvmrc
rm .nvmrc
```

### Multi-Tool Projects

```bash
# Full-stack project with multiple tools
mise use node@22 go@1.21 python@3.12 terraform@1.6

# Creates mise.toml with all tools
# Now cd into directory auto-activates all versions
```

## Advanced Usage

### Execute with Specific Version

```bash
# Run command with different Node version
mise exec node@18 -- node my-script.js

# Test across multiple versions
mise exec node@18 -- npm test
mise exec node@20 -- npm test
mise exec node@22 -- npm test
```

### Watch Mode

```bash
# Watch files and rerun task on changes
mise watch -t test

# Watch specific patterns
mise watch -g '*.js' -t build
```

### Shell Completions

```bash
# Already configured in .zshrc/.bashrc
# But if needed manually:
mise completion zsh > /usr/local/share/zsh/site-functions/_mise
```

## Troubleshooting

### Check mise Health

```bash
mise doctor
```

### Clear Cache

```bash
mise cache clear
```

### Verbose Output

```bash
mise -v install node@22
MISE_DEBUG=1 mise install node@22
```

### Uninstall Version

```bash
mise uninstall node@18.0.0
```

### Plugin Issues

```bash
# Update plugins
mise plugin update --all

# Reinstall plugin
mise plugin uninstall node
mise plugin install node
```

## Configuration Files

### Priority Order (highest to lowest)

1. `./mise.toml` - Project-specific (current directory)
2. `./mise.local.toml` - Project-specific, gitignored
3. `~/.config/mise/config.toml` - Global user config
4. `/etc/mise/config.toml` - System-wide config

### Example Project Structure

```
my-project/
├── mise.toml              # Tracked in git
├── mise.local.toml        # Local overrides (gitignored)
├── .env                   # Can be loaded by mise
├── package.json
└── src/
```

## Tips for Node.js Developers

### Replace nvm/nodenv

```bash
# Old way (nvm)
nvm use 22
nvm install 20
nvm alias default 22

# New way (mise)
mise use -g node@22        # Global default
mise use node@20           # Project-specific
# Auto-switches on cd!
```

### Replace direnv

```bash
# Old way (.envrc)
export NODE_ENV=development
export API_URL=http://localhost:3000

# New way (mise.toml)
[env]
NODE_ENV = "development"
API_URL = "http://localhost:3000"
```

### Replace Makefile/npm scripts

```bash
# Old way (package.json)
"scripts": {
  "dev": "next dev",
  "build": "next build",
  "test": "jest"
}

# New way (mise.toml) - can coexist!
[tasks.dev]
run = "pnpm run dev"

[tasks.ci]
run = """
pnpm run lint
pnpm run test
pnpm run build
"""

# Then: mise run dev, mise run ci
```

### Quick Aliases (already in dotfiles)

```bash
mi          # mise install
mu          # mise use
ml          # mise list
mr          # mise run
mt          # mise task run
```

## Resources

- [mise Documentation](https://mise.jdx.dev/)
- [Node.js Plugin](https://mise.jdx.dev/lang/node.html)
- [mise Registry](https://mise.jdx.dev/registry.html) - All supported tools
- [Task Runner Guide](https://mise.jdx.dev/tasks/)
- [Environment Variables](https://mise.jdx.dev/environments/)
