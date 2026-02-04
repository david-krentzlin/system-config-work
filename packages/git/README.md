# Git Worktree Workflow

Simple shell functions for managing git worktrees in a bare repository setup.

## Workflow Overview

1. **Clone as bare repo**: `git-bare-clone <repo-url>`
2. **Create main worktree**: `git-worktree-main`
3. **Create feature worktrees**: `git-worktree-new feature/branch-name`
4. **Work in each worktree** (each in its own directory/tab)
5. **Clean up**: `git-worktree-remove feature/branch-name`

## Directory Structure

```
project/
  .git/          # Bare repository
  main/          # Main branch worktree
  feature-x/     # Feature branch worktree
  bugfix-y/      # Another feature worktree
```

## Commands

### `git-bare-clone <repo-url> [target-dir]`

Clone a repository as a bare repo, ready for worktrees.

```bash
git-bare-clone git@github.com:user/repo.git
# Creates: repo/.git/

git-bare-clone git@github.com:user/repo.git my-project
# Creates: my-project/.git/
```

Alias: `gwb`

### `git-worktree-convert [new-parent-dir]`

Convert an existing regular git clone to the worktree-based setup. Run this from inside your existing repository.

```bash
cd ~/projects/my-repo
git-worktree-convert
# Converts in place, creating:
# ~/projects/my-repo/.git/           (bare repo)
# ~/projects/my-repo/main/            (worktree)

git-worktree-convert ~/NewWork/Code
# Converts and moves to new location:
# ~/NewWork/Code/my-repo/.git/        (bare repo)
# ~/NewWork/Code/my-repo/main/        (worktree)
```

**Important**: Make sure you have no uncommitted changes before converting!

Alias: `gwc`

### `git-worktree-main [branch-name]`

Create the main/master worktree from a bare repository. Automatically detects whether the repo uses `main` or `master` (prefers `main` if both exist).

```bash
cd my-project
git-worktree-main        # Auto-detects main or master
git-worktree-main master # Force specific branch
```

### `git-worktree-new <branch-name> [base-branch]`

Create a new branch and worktree. Copies the branch name to clipboard. Automatically detects whether to base off `main` or `master` (prefers `main` if both exist).

```bash
git-worktree-new feature/new-ui              # Auto-detects main/master
git-worktree-new bugfix/login-error main     # Force specific base
git-worktree-new hotfix/prod-issue master    # Force specific base
```

Alias: `gwn`

### `git-worktree-list`

List all worktrees.

```bash
git-worktree-list
```

Alias: `gwl`

### `git-worktree-remove <branch-name>`

Remove a worktree and optionally delete the branch.

```bash
git-worktree-remove feature/old-ui
```

Alias: `gwr`

## Usage with Wezterm

Each worktree can be a tab in your wezterm workspace:

1. Create worktree: `git-worktree-new feature/new-ui`
2. Open new wezterm tab
3. `cd feature/new-ui`
4. Work on the feature
5. Switch tabs to work on different branches

Branch name is automatically copied to clipboard for easy pasting in commit messages, PR titles, etc.
