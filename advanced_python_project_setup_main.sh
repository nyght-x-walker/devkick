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
git init

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
echo "[tool.poetry]" >> pyproject.toml
echo "packages = [{ include = \"$PROJECT_NAME\" }]" >> pyproject.toml

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
cat << EOF > LICENSE
MIT License

Copyright (c) 2025 nyght-x-walkker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction [...shortened...]
EOF

# Setup .envrc for direnv
echo "use poetry" > .envrc
direnv allow

# Create source and test directories
mkdir app tests

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
cat << 'EOF' > "$git_dir/python-app.yml"
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
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: "$PYTHON_VERSION"
    - name: Install Poetry
      run: |
        curl -sSL https://install.python-poetry.org | python3 -
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> $GITHUB_ENV
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
# ⚡ Devkick

> A lightning-fast way to spin up new Python projects with best practices built-in ⚙️🔥

![CI](https://github.com/nyght-x-walker/devkick/actions/workflows/python-app.yml/badge.svg)

Devkick is a high-voltage Python project scaffolding tool that helps you launch clean, modern, and production-ready environments in seconds.

No more repetitive setup. No more clutter. Just one command and boom, you're ready to code.

---

### 🚀 Why Devkick?

Full dev environment** in one go: `pyenv`, `poetry`, `direnv`, and `Makefile`-based workflows.
 Clean architecture with `app/`, `tests/`, and GitHub Actions out of the box.
 Automatic virtualenv & dependency management.
 Built-in testing, linting, and coverage reporting.
 Compatible with `requirements.txt` export for other tooling.

---

### 🛠 Requirements

 [pyenv](https://github.com/pyenv/pyenv)
 [poetry](https://python-poetry.org/docs/#installation)
 [direnv](https://direnv.net/)

---

 \`pyenv\` – Python version management
 \`poetry\` – Dependency management and virtualenvs
 \`direnv\` – Auto-activation of environments
 \`Makefile\` – Simplified development workflow
 GitHub Actions CI/CD workflow
 Coverage reporting with \`coverage.py\`
 \`requirements.txt\` for tool compatibility


### ⚙️ Quick Start

```bash
chmod +x advanced_python_project_setup.sh
./advanced_python_project_setup.sh


# Then...

  cd devkick
  make setup
  make run


📂 What You Get

  app/ → Your main Python source code
  tests/ → Ready-to-go Pytest testing setup
  python-version → Isolated with pyenv
  envrc → Automatic env loading via direnv
  pyproject.toml → Managed with poetry
  Makefile → Run commands like make test, make lint, etc.
  github/workflows/ → CI pipeline with GitHub Actions
EOF

echo "✅ Project '$PROJECT_NAME' setup complete!"
