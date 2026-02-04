# Git Worktree Workflow Functions
# Simple shell functions for managing git worktrees in a bare repository setup

# Detect the main branch name (main or master, preferring main)
_git_main_branch() {
    if [[ ! -d ".git" ]]; then
        echo "main"
        return
    fi

    # Check if we have main branch
    if git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null || \
       git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
        echo "main"
        return
    fi

    # Fall back to master
    if git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null || \
       git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
        echo "master"
        return
    fi

    # Default to main if nothing found
    echo "main"
}

# Clone a repository as a bare repo and set up the main worktree
# Usage: git-bare-clone <repo-url> [target-dir]
git-bare-clone() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: git-bare-clone <repo-url> [target-dir]"
        echo "Example: git-bare-clone git@github.com:user/repo.git"
        return 1
    fi

    local repo_url="$1"
    local target_dir="$2"

    # Extract repo name from URL if target not provided
    if [[ -z "$target_dir" ]]; then
        target_dir=$(basename "$repo_url" .git)
    fi

    # Create the bare repository
    echo "Cloning bare repository to $target_dir/.git..."
    git clone --bare "$repo_url" "$target_dir/.git"

    if [[ $? -ne 0 ]]; then
        echo "Failed to clone repository"
        return 1
    fi

    # Configure the bare repo to not show status warnings
    pushd "$target_dir/.git"
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    popd


    echo "✓ Bare repository created at $target_dir/.git"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Next: cd $target_dir && git-worktree-main"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Check out the main branch as a worktree
# Usage: git-worktree-main [branch-name]
git-worktree-main() {
    # Check if we're in a bare repo directory structure
    if [[ ! -d ".git" ]]; then
        echo "Error: No .git directory found. Run this from the repository root."
        return 1
    fi

    # Auto-detect main branch if not specified
    local branch="${1:-$(_git_main_branch)}"

    # If .git is a directory (bare repo), add worktree
    if [[ -d ".git/worktrees" ]] || [[ -f ".git/config" ]] && grep -q "bare = true" ".git/config" 2>/dev/null; then
        echo "Adding $branch worktree..."
        git worktree add "$branch" "$branch"

        if [[ $? -eq 0 ]]; then
            echo "✓ Worktree created at ./$branch"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Next: cd $branch"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
    else
        echo "Error: This doesn't appear to be a bare repository"
        return 1
    fi
}

# Create a new branch and worktree, and copy the branch name to clipboard
# Usage: git-worktree-new <branch-name> [base-branch]
git-worktree-new() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: git-worktree-new <branch-name> [base-branch]"
        echo "Example: git-worktree-new feature/new-ui"
        return 1
    fi

    local branch_name="$1"
    # Auto-detect main branch if not specified
    local base_branch="${2:-$(_git_main_branch)}"

    # Check if we're in a bare repo directory structure
    if [[ ! -d ".git" ]]; then
        echo "Error: No .git directory found. Run this from the repository root."
        return 1
    fi

    # Check if worktree directory already exists
    if [[ -d "$branch_name" ]]; then
        echo "Error: Worktree directory '$branch_name' already exists"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Next: cd $branch_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        return 0
    fi

    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/"$branch_name" 2>/dev/null; then
        echo "Branch '$branch_name' already exists."
        echo ""
        echo "Creating worktree for existing branch..."
        git worktree add "$branch_name" "$branch_name"
    else
        echo "Creating worktree for new branch: $branch_name (based on $base_branch)"
        git worktree add -b "$branch_name" "$branch_name" "$base_branch"
    fi

    if [[ $? -eq 0 ]]; then
        echo "✓ Worktree created at ./$branch_name"

        # Copy branch name to clipboard
        if command -v pbcopy >/dev/null 2>&1; then
            echo -n "$branch_name" | pbcopy
            echo "✓ Branch name copied to clipboard: $branch_name"
        elif command -v xclip >/dev/null 2>&1; then
            echo -n "$branch_name" | xclip -selection clipboard
            echo "✓ Branch name copied to clipboard: $branch_name"
        else
            echo "Branch name: $branch_name (clipboard tool not found)"
        fi

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Next: cd $branch_name"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        echo "Failed to create worktree"
        return 1
    fi
}

# List all worktrees
# Usage: git-worktree-list
git-worktree-list() {
    if [[ ! -d ".git" ]]; then
        echo "Error: No .git directory found. Run this from the repository root."
        return 1
    fi

    git worktree list
}

# Remove a worktree
# Usage: git-worktree-remove <branch-name>
git-worktree-remove() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: git-worktree-remove <branch-name>"
        echo "Example: git-worktree-remove feature/old-ui"
        return 1
    fi

    local branch_name="$1"

    if [[ ! -d "$branch_name" ]]; then
        echo "Error: Worktree directory '$branch_name' not found"
        return 1
    fi

    echo "Removing worktree: $branch_name"
    git worktree remove "$branch_name"

    if [[ $? -eq 0 ]]; then
        echo "✓ Worktree removed: $branch_name"

        # Ask if user wants to delete the branch
        echo ""
        echo -n "Delete branch '$branch_name'? [y/N] "
        read response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git branch -D "$branch_name"
            echo "✓ Branch deleted: $branch_name"
        fi
    else
        echo "Failed to remove worktree"
        return 1
    fi
}

# Convert an existing regular clone to worktree-based setup
# Usage: git-worktree-convert [new-parent-dir]
git-worktree-convert() {
    # Must be run from inside a git repository
    if [[ ! -d ".git" ]] || [[ ! -f ".git/config" ]]; then
        echo "Error: Not in a git repository or already a worktree"
        return 1
    fi

    # Check if it's already a bare repo
    if grep -q "bare = true" ".git/config" 2>/dev/null; then
        echo "Error: This is already a bare repository"
        return 1
    fi

    # Get the current branch
    local current_branch=$(git branch --show-current)
    if [[ -z "$current_branch" ]]; then
        echo "Error: Could not determine current branch"
        return 1
    fi

    # Get the repository root and name
    local repo_root=$(git rev-parse --show-toplevel)
    local repo_name=$(basename "$repo_root")
    local parent_dir=$(dirname "$repo_root")

    # Allow specifying a different parent directory
    local new_parent="${1:-$parent_dir}"
    local new_location="$new_parent/$repo_name"

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo "Error: You have uncommitted changes. Please commit or stash them first."
        return 1
    fi

    echo "Converting $repo_root to worktree-based setup..."
    echo "Current branch: $current_branch"
    echo "Target location: $new_location"
    echo ""
    echo -n "Continue? [y/N] "
    read response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Aborted"
        return 1
    fi

    # Get the remote URL before we move things around
    local remote_url=$(git remote get-url origin 2>/dev/null)

    # Create a temporary name for the transition
    local temp_dir="${new_location}.tmp"

    # Step 1: Move current .git to temporary location
    echo "Step 1: Creating bare repository..."
    mv "$repo_root/.git" "$temp_dir"

    # Step 2: Configure it as a bare repository
    cd "$temp_dir"
    git config --bool core.bare true
    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

    # Step 3: Create the new structure
    echo "Step 2: Setting up new directory structure..."
    mkdir -p "$new_location"
    mv "$temp_dir" "$new_location/.git"

    # Step 4: Create worktree for the current branch
    echo "Step 3: Creating worktree for $current_branch..."
    cd "$new_location"
    git worktree add "$current_branch" "$current_branch"

    # Step 5: Copy over any untracked files from the old location
    echo "Step 4: Moving working directory contents..."

    # Check if we're doing in-place conversion or moving to new location
    if [[ "$repo_root" != "$new_location" ]]; then
        # Moving to a different location - copy files and ask about cleanup
        rsync -a --exclude='.git' "$repo_root/" "$new_location/$current_branch/"

        echo ""
        echo -n "Remove old directory $repo_root? [y/N] "
        read response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -rf "$repo_root"
            echo "✓ Old directory removed"
        else
            echo "Note: Old directory left at $repo_root (you can remove it manually)"
        fi
    else
        # In-place conversion - move files from root into worktree subdirectory
        # First, move all files (except .git which is already moved) into the worktree
        for item in "$repo_root"/*; do
            # Skip .git and the new worktree directory
            local basename=$(basename "$item")
            if [[ "$basename" != ".git" && "$basename" != "$current_branch" ]]; then
                mv "$item" "$new_location/$current_branch/"
            fi
        done

        # Also move hidden files
        for item in "$repo_root"/.[^.]*; do
            if [[ -e "$item" ]]; then
                local basename=$(basename "$item")
                if [[ "$basename" != ".git" ]]; then
                    mv "$item" "$new_location/$current_branch/"
                fi
            fi
        done

        echo "✓ Files moved to worktree"
    fi

    echo ""
    echo "✓ Conversion complete!"
    echo "✓ Bare repository: $new_location/.git"
    echo "✓ Working directory: $new_location/$current_branch"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Next: cd $new_location/$current_branch"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Aliases for convenience
alias gwb='git-bare-clone'
alias gwc='git-worktree-convert'
alias gwl='git-worktree-list'
alias gwn='git-worktree-new'
alias gwr='git-worktree-remove'
