# mise-tasks/ - File-based Task Examples

This directory contains example file-based tasks for mise. These are an alternative to defining tasks in `mise.toml`.

## Benefits of File-based Tasks

1. **Executable scripts**: Can be run directly (e.g., `./mise-tasks/build`)
2. **Language flexibility**: Can be written in any language (bash, python, node, etc.)
3. **Complex logic**: Better for multi-step tasks with conditionals
4. **Version control**: Easier to track changes in git
5. **IDE support**: Better syntax highlighting and linting

## Task Structure

```bash
#!/usr/bin/env bash
#MISE description="Task description shown in 'mise tasks'"
#MISE depends="other-task another-task"
#MISE alias="t"
#MISE sources="src/**/*.ts"
#MISE outputs="dist/**/*"

# Your task code here
```

## Metadata Comments

- `#MISE description`: Description shown in `mise tasks` output
- `#MISE depends`: Space-separated list of task dependencies
- `#MISE alias`: Short alias for the task
- `#MISE sources`: File patterns to watch (for smart rebuilding)
- `#MISE outputs`: Output file patterns

## Usage

1. **Create tasks directory** in your project:
   ```bash
   mkdir -p mise-tasks
   ```

2. **Copy example tasks**:
   ```bash
   cp ~/dotfiles/mise-tasks-examples/* mise-tasks/
   chmod +x mise-tasks/*
   ```

3. **Run tasks**:
   ```bash
   mise run build
   mise run test
   mise run deploy-staging
   ```

4. **List available tasks**:
   ```bash
   mise tasks
   ```

## Task Discovery

mise automatically discovers tasks from:
- `mise-tasks/` directory
- `.mise/tasks/` directory  
- `mise.toml` `[tasks.*]` sections

## Examples Included

- **build** - Build the project with dependencies
- **test** - Run tests with coverage
- **deploy-staging** - Deploy to staging with safety checks
- **clean** - Clean development environment

## Creating Your Own Tasks

```bash
# Create a new task
cat > mise-tasks/my-task << 'EOF'
#!/usr/bin/env bash
#MISE description="My custom task"

echo "Running my task..."
# Your code here
EOF

# Make it executable
chmod +x mise-tasks/my-task

# Run it
mise run my-task
```

## Advanced: Multi-language Tasks

### Python Task
```python
#!/usr/bin/env python3
#MISE description="Python-based task"

print("Running Python task...")
# Your Python code here
```

### Node.js Task
```javascript
#!/usr/bin/env node
//MISE description="Node.js-based task"

console.log("Running Node.js task...");
// Your JavaScript code here
```

## Best Practices

1. **Use set -e**: Exit on error in bash scripts
2. **Add descriptions**: Always include `#MISE description`
3. **Handle errors**: Provide clear error messages
4. **Make executable**: `chmod +x mise-tasks/*`
5. **Use dependencies**: Leverage `#MISE depends` for task ordering
6. **Add validation**: Check preconditions before running

## Integration with mise.toml

You can mix file-based tasks with TOML tasks:

```toml
# mise.toml
[tasks.all]
description = "Run all tasks"
depends = ["build", "test", "deploy-staging"]  # File-based tasks
```

mise will automatically find and use both types of tasks.
