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
