#!/usr/bin/env sh

# devkick_project_setup.sh
# Shell-agnostic project scaffolding: works with zsh, bash, etc.

PROJECT_NAME="${1:-devkick}"  # Allow project name to be passed in as an argument

# Get the system's active Python version
PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')

# Check if the version is available
if [ -z "$PYTHON_VERSION" ]; then
  echo "❌ No active Python version found on the system. Please ensure Python is installed."
  exit 1
fi

echo "Using system's active Python version: $PYTHON_VERSION"

# Check required tools
command -v pyenv >/dev/null 2>&1 || { echo "❌ pyenv not found. Install it first."; exit 1; }
command -v poetry >/dev/null 2>&1 || { echo "❌ poetry not found. Install it first."; exit 1; }
command -v direnv >/dev/null 2>&1 || { echo "❌ direnv not found. Install it first."; exit 1; }

# Check if directory exists
if [ -d "$PROJECT_NAME" ]; then
  echo "❌ Project directory '$PROJECT_NAME' already exists. Aborting to avoid overwrite."
  exit 1
fi

# Create project directory
mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME" || exit 1

# Initialize git repo
git init -b main

# Set Python version
echo "$PYTHON_VERSION" > .python-version

# Check if desired Python version is already installed
if ! pyenv versions --bare | grep -qx "$PYTHON_VERSION"; then
  echo "🔧 Installing Python $PYTHON_VERSION via pyenv..."
  pyenv install "$PYTHON_VERSION"
else
  echo "✅ Python $PYTHON_VERSION already installed."
fi

pyenv local "$PYTHON_VERSION"

# Initialize poetry project
poetry init --name "$PROJECT_NAME" --python="$PYTHON_VERSION" --no-interaction

# Inject source package info
python - <<'PY'
import pathlib

path = pathlib.Path("pyproject.toml")
text = path.read_text()
entry = 'packages = [{ include = "app" }]\n'
path.write_text(text.replace("[tool.poetry]\n", "[tool.poetry]\n" + entry, 1))
PY

# Create .gitignore
cat << EOF > .gitignore
.venv/
__pycache__/
*.pyc
.pytest_cache/
.coverage
dist/
build/
*.egg-info/
EOF

# Create README.md early to prevent Poetry error
cat << EOF > README.md
# ⚡ Devkick

![CI](https://github.com/nyght-x-walker/devkick/actions/workflows/python-app.yml/badge.svg)

See full setup instructions in this file.
EOF

# Create LICENSE
cat << 'EOF' > LICENSE
MIT License

Copyright (c) 2025 nyght-x-walker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Setup .envrc for direnv
echo "use poetry" > .envrc
direnv allow

# Create source and test directories
mkdir app tests
touch app/__init__.py tests/__init__.py

# Add dependencies
poetry add requests
poetry add --group dev black pytest coverage

# Generate requirements.txt for alternative tooling
poetry export --without-hashes -f requirements.txt > requirements.txt

# Create Makefile
cat << 'EOF' > Makefile
setup:
	poetry install

run:
	poetry run python app/main.py

test:
	poetry run pytest

lint:
	poetry run black .

coverage:
	poetry run coverage run -m pytest && poetry run coverage report -m
EOF

# Create sample main code
cat << EOF > app/main.py
def main():
    print("Hello from $PROJECT_NAME!")

if __name__ == "__main__":
    main()
EOF

# Create placeholder test
cat << 'EOF' > tests/test_dummy.py
def test_dummy():
    assert True
EOF

# GitHub Actions workflow
git_dir=".github/workflows"
mkdir -p "$git_dir"
cat << EOF > "$git_dir/python-app.yml"
name: Python application

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: "$PYTHON_VERSION"
    - name: Install Poetry
      run: |
        curl -sSL https://install.python-poetry.org | python3 -
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> \$GITHUB_ENV
    - name: Install dependencies
      run: poetry install
    - name: Run tests
      run: poetry run pytest
    - name: Coverage report
      run: |
        poetry run coverage run -m pytest
        poetry run coverage report
EOF

# Update README with full instructions
cat << 'EOF' > README.md
# Devkick

A clean Python project scaffold with pyenv, Poetry, direnv, a Makefile, tests, and CI.

![CI](https://github.com/nyght-x-walker/devkick/actions/workflows/python-app.yml/badge.svg)

## Quick start

```bash
make setup
make run
make test
```

## What you get

- `.python-version` pinned to the active Python version
- `pyproject.toml` managed with Poetry
- `.envrc` wired for direnv
- `app/` and `tests/` starter layout
- A Makefile with `setup`, `run`, `test`, `lint`, and `coverage`
- GitHub Actions CI for tests and coverage
- `requirements.txt` export for tooling that does not use Poetry
- MIT license

## Make targets

```bash
make setup     # install dependencies
make run       # run app/main.py
make test      # run pytest
make lint      # run black
make coverage  # run coverage and print a report
```
EOF

echo "✅ Project '$PROJECT_NAME' setup complete!"
