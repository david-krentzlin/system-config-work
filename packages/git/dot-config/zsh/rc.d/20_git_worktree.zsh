# Git Worktree Workflow Functions
# Zoxide-friendly worktree management with separate directories for main branches and worktrees
#
# Directory Structure:
#   $DK_CODE_PATH/<forge>/<org>/<repo>@main          - Main branch checkout
#   $DK_WORKTREES_PATH/<forge>/<org>/<repo>@<branch> - Worktree for branch
#
# Functions:
#   wt  <branch> [base]  - Create worktree and copy path to clipboard
#   wtl                  - List worktrees
#   wtr <branch>         - Remove worktree
#   wtj [branch]         - Jump to existing worktree (fuzzy-find if no branch)
#   wtc <repo-url>       - Clone repository (supports shorthand, defaults to SSH)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Parse repository information from current directory path
# Sets: $forge, $org, $repo_base
_wt_parse_repo_info() {
    local full_path="$PWD"
    local relative_path=""

    # Check if we're under DK_CODE_PATH or DK_WORKTREES_PATH
    if [[ "$full_path" == "$DK_CODE_PATH"* ]]; then
        relative_path="${full_path#$DK_CODE_PATH/}"
    elif [[ "$full_path" == "$DK_WORKTREES_PATH"* ]]; then
        relative_path="${full_path#$DK_WORKTREES_PATH/}"
    else
        echo "Error: Not in a known code directory"
        echo "Expected: $DK_CODE_PATH or $DK_WORKTREES_PATH"
        return 1
    fi

    # Remove @branch suffix if present
    local path_without_branch="${relative_path%%@*}"

    # Split by /
    local parts=("${(@s:/:)path_without_branch}")
    if [[ ${#parts[@]} -lt 3 ]]; then
        echo "Error: Could not parse repository path"
        echo "Expected format: <forge>/<org>/<repo>"
        echo "Current path: $relative_path"
        return 1
    fi

    forge="${parts[1]}"
    org="${parts[2]}"
    # Remaining parts form the repo name (handles repos with hyphens/underscores)
    repo_base="${(j:/:)parts[3,-1]}"

    return 0
}

# Detect main branch name (main or master)
_wt_detect_main_branch() {
    # Check local branches first
    if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
        echo "main"
        return
    fi

    if git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
        echo "master"
        return
    fi

    # Check remote branches
    if git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null; then
        echo "main"
        return
    fi
    
    if git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null; then
        echo "master"
        return
    fi

    # Default to main
    echo "main"
}

# Copy text to clipboard (cross-platform)
_wt_copy_to_clipboard() {
    local text="$1"

    if command -v pbcopy >/dev/null 2>&1; then
        echo -n "$text" | pbcopy
        return 0
    elif command -v xclip >/dev/null 2>&1; then
        echo -n "$text" | xclip -selection clipboard
        return 0
    elif command -v wl-copy >/dev/null 2>&1; then
        echo -n "$text" | wl-copy
        return 0
    else
        echo "Warning: No clipboard tool found (pbcopy/xclip/wl-copy)"
        return 1
    fi
}

# Sanitize branch name for use in filesystem paths
# Replaces / with _ and removes problematic characters
_wt_sanitize_branch_name() {
    local branch_name="$1"

    # Replace / with _
    branch_name="${branch_name//\//_}"
    # Remove characters that are problematic in paths
    # Keep: alphanumeric, dash, underscore, dot
    branch_name="${branch_name//[^a-zA-Z0-9._-]/}"
    echo "$branch_name"
}

# ============================================================================
# MAIN FUNCTIONS
# ============================================================================

# Create a new worktree
# Usage: wt <branch-name> [base-branch]
wt() {
    local branch_name="$1"
    local base_branch="$2"

    if [[ -z "$branch_name" ]]; then
        echo "Usage: wt <branch-name> [base-branch]"
        echo ""
        echo "Examples:"
        echo "  wt feature/new-thing       # Create worktree from current branch"
        echo "  wt hotfix/bug develop      # Create worktree from 'develop' branch"
        echo ""
        echo "The worktree will be created at:"
        echo "  \$DK_WORKTREES_PATH/<forge>/<org>/<repo>@<branch>"
        return 1
    fi


    # Verify we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Parse repository info from current path
    local forge org repo_base
    if ! _wt_parse_repo_info; then
        return 1
    fi

    # Sanitize branch name for filesystem
    local sanitized_branch=$(_wt_sanitize_branch_name "$branch_name")

    if [[ "$sanitized_branch" != "$branch_name" ]]; then
        echo "Note: Branch name sanitized for filesystem: $branch_name -> $sanitized_branch"
    fi

    # Build target worktree path
    local worktree_path="$DK_WORKTREES_PATH/${forge}/${org}/${repo_base}@${sanitized_branch}"

    # Check if worktree directory already exists
    if [[ -d "$worktree_path" ]]; then
        echo "Error: Worktree directory already exists:"
        echo "  $worktree_path"
        echo ""
        echo "Next: cd \"$worktree_path\""
        return 1
    fi

    # Create parent directories if needed
    mkdir -p "$(dirname "$worktree_path")"

    # Determine base branch (default to current branch)
    if [[ -z "$base_branch" ]]; then
        base_branch=$(git branch --show-current)
        if [[ -z "$base_branch" ]]; then
            echo "Error: Could not determine current branch"
            return 1
        fi
    fi

    # Check if branch already exists
    local branch_exists=0
    if git show-ref --verify --quiet refs/heads/"$branch_name" 2>/dev/null; then
        branch_exists=1
    fi

    # Create worktree
    echo "Creating worktree: $branch_name (from $base_branch)"
    if [[ $branch_exists -eq 1 ]]; then
        echo "Branch '$branch_name' exists, checking out..."
        git worktree add "$worktree_path" "$branch_name"
    else
        echo "Creating new branch '$branch_name'..."
        git worktree add -b "$branch_name" "$worktree_path" "$base_branch"
    fi

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create worktree"
        return 1
    fi

    # Copy path to clipboard
    if _wt_copy_to_clipboard "$worktree_path"; then
        echo ""
        echo "Worktree created: $worktree_path"
        echo "Path copied to clipboard"
    else
        echo ""
        echo "Worktree created: $worktree_path"
    fi

    echo ""
    echo "Next: cd \"$worktree_path\""
}

# List all worktrees for current repository
# Usage: wtl
wtl() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi
    
    git worktree list
}

# Remove a worktree
# Usage: wtr <branch-name>
wtr() {
    local branch_name="$1"
    
    if [[ -z "$branch_name" ]]; then
        echo "Usage: wtr <branch-name>"
        echo "Example: wtr feature/old-thing"
        return 1
    fi
    
    # Verify we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi
    
    # Parse repository info
    local forge org repo_base
    if ! _wt_parse_repo_info; then
        return 1
    fi
    
    # Sanitize branch name
    local sanitized_branch=$(_wt_sanitize_branch_name "$branch_name")
    
    # Build expected worktree path
    local worktree_path="$DK_WORKTREES_PATH/${forge}/${org}/${repo_base}@${sanitized_branch}"
    
    # Check if worktree exists
    if [[ ! -d "$worktree_path" ]]; then
        echo "Error: Worktree not found:"
        echo "  $worktree_path"
        echo ""
        echo "Available worktrees:"
        git worktree list
        return 1
    fi
    
    # Remove worktree
    echo "Removing worktree: $worktree_path"
    git worktree remove "$worktree_path"
    
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to remove worktree"
        return 1
    fi
    
    echo "Worktree removed"
    
    # Ask if user wants to delete the branch
    echo ""
    echo -n "Delete branch '$branch_name'? [y/N] "
    read response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git branch -D "$branch_name"
        if [[ $? -eq 0 ]]; then
            echo "Branch deleted: $branch_name"
        else
            echo "Failed to delete branch"
        fi
    fi
}

# Clone a repository with @main/@master suffix
# Usage: wtc <repo-url> [target-dir]
# Supports shorthand: wtc github.com/org/repo (defaults to SSH)
wtc() {
    local repo_url="$1"
    local target_dir="$2"
    
    if [[ -z "$repo_url" ]]; then
        echo "Usage: wtc <repo-url> [target-dir]"
        echo ""
        echo "Examples:"
        echo "  wtc github.com/user/repo              # Shorthand (SSH)"
        echo "  wtc git@github.com:user/repo.git      # Full SSH URL"
        echo "  wtc https://github.com/user/repo.git  # HTTPS URL"
        echo ""
        echo "The repository will be cloned to:"
        echo "  \$DK_CODE_PATH/<forge>/<org>/<repo>@main"
        return 1
    fi

    # Parse repository information from URL
    local forge org repo_name
    local actual_clone_url="$repo_url"
    
    # Handle different URL formats
    if [[ "$repo_url" =~ ^git@([^:]+):([^/]+)/(.+)\.git$ ]]; then
        # SSH format: git@github.com:user/repo.git
        forge="${match[1]}"
        org="${match[2]}"
        repo_name="${match[3]}"
    elif [[ "$repo_url" =~ ^https?://([^/]+)/([^/]+)/(.+)\.git$ ]]; then
        # HTTPS format: https://github.com/user/repo.git
        forge="${match[1]}"
        org="${match[2]}"
        repo_name="${match[3]}"
    elif [[ "$repo_url" =~ ^git@([^:]+):([^/]+)/(.+)$ ]]; then
        # SSH without .git: git@github.com:user/repo
        forge="${match[1]}"
        org="${match[2]}"
        repo_name="${match[3]}"
    elif [[ "$repo_url" =~ ^https?://([^/]+)/([^/]+)/(.+)$ ]]; then
        # HTTPS without .git: https://github.com/user/repo
        forge="${match[1]}"
        org="${match[2]}"
        repo_name="${match[3]}"
    elif [[ "$repo_url" =~ ^([^/:]+)/([^/]+)/(.+)\.git$ ]]; then
        # Shorthand with .git: github.com/org/repo.git (default to SSH)
        forge="${match[1]}"
        org="${match[2]}"
        repo_name="${match[3]}"
        actual_clone_url="git@${forge}:${org}/${repo_name}.git"
    elif [[ "$repo_url" =~ ^([^/:]+)/([^/]+)/(.+)$ ]]; then
        # Shorthand without .git: github.com/org/repo (default to SSH)
        forge="${match[1]}"
        org="${match[2]}"
        repo_name="${match[3]}"
        actual_clone_url="git@${forge}:${org}/${repo_name}.git"
    else
        echo "Error: Could not parse repository URL"
        echo "Supported formats:"
        echo "  github.com/org/repo (shorthand, defaults to SSH)"
        echo "  git@forge.com:org/repo.git"
        echo "  https://forge.com/org/repo.git"
        return 1
    fi

    # Determine target directory
    if [[ -z "$target_dir" ]]; then
        # Use temporary name for cloning
        target_dir="$DK_CODE_PATH/${forge}/${org}/${repo_name}.tmp"
    fi

    # Create parent directory
    mkdir -p "$(dirname "$target_dir")"

    # Clone repository
    echo "Cloning repository..."
    git clone "$actual_clone_url" "$target_dir"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to clone repository"
        return 1
    fi

    # Detect main branch
    cd "$target_dir"
    local main_branch=$(_wt_detect_main_branch)
    cd - > /dev/null

    # Build final directory name
    local final_dir="$DK_CODE_PATH/${forge}/${org}/${repo_name}@${main_branch}"

    # Rename to include branch suffix
    if [[ "$target_dir" != "$final_dir" ]]; then
        mv "$target_dir" "$final_dir"
    fi

    echo ""
    echo "Repository cloned"
    echo "Location: $final_dir"
    echo ""
    echo "Next: cd \"$final_dir\""
}

# Jump to an existing worktree with fuzzy-find support
# Usage: wtj [branch-name]
# If branch-name is omitted or not found, opens fzf to select
wtj() {
    local branch_name="$1"

    # Verify we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Get current worktree path to exclude it from selection
    local current_path="$PWD"

    # Get list of all worktrees from git
    local -a worktrees
    local -a worktree_paths
    local -a worktree_branches
    
    # Parse git worktree list output
    # Format: /path/to/worktree  commit-hash [branch-name]
    while IFS= read -r line; do
        # Extract path (first field)
        local wt_path="${line%% *}"
        
        # Skip bare repositories
        if [[ "$line" == *"(bare)"* ]]; then
            continue
        fi
        
        # Skip current worktree
        if [[ "$wt_path" == "$current_path" ]]; then
            continue
        fi
        
        # Extract branch name from brackets
        if [[ "$line" =~ \[([^\]]+)\] ]]; then
            local branch="${match[1]}"
            worktree_paths+=("$wt_path")
            worktree_branches+=("$branch")
        fi
    done < <(git worktree list --porcelain | grep -E '^worktree |^branch ' | paste -d ' ' - - | sed 's/worktree //; s/branch //')

    # Alternative simpler parsing if the above doesn't work
    if [[ ${#worktree_paths[@]} -eq 0 ]]; then
        while IFS= read -r line; do
            local wt_path="${line%% *}"
            
            # Skip bare repos
            if [[ "$line" == *"(bare)"* ]]; then
                continue
            fi
            
            # Skip current worktree
            if [[ "$wt_path" == "$current_path" ]]; then
                continue
            fi
            
            # Try to extract branch from the path (last component after @)
            if [[ "$wt_path" =~ @([^/]+)$ ]]; then
                local branch="${match[1]}"
                worktree_paths+=("$wt_path")
                worktree_branches+=("$branch")
            fi
        done < <(git worktree list)
    fi

    # If no worktrees found
    if [[ ${#worktree_paths[@]} -eq 0 ]]; then
        echo "No worktrees found for this repository"
        echo ""
        echo "Available worktrees:"
        git worktree list
        return 1
    fi

    local worktree_path=""
    local selected_index=-1

    # If branch name provided, try to find exact match first
    if [[ -n "$branch_name" ]]; then
        local sanitized_branch=$(_wt_sanitize_branch_name "$branch_name")
        
        # Try to find matching branch
        for i in {1..${#worktree_branches[@]}}; do
            local wt_branch="${worktree_branches[$i]}"
            local wt_branch_sanitized=$(_wt_sanitize_branch_name "$wt_branch")
            
            if [[ "$wt_branch" == "$branch_name" ]] || [[ "$wt_branch_sanitized" == "$sanitized_branch" ]]; then
                worktree_path="${worktree_paths[$i]}"
                selected_index=$i
                break
            fi
        done
    fi

    # If no exact match found (or no branch name provided), use fuzzy finder
    if [[ -z "$worktree_path" ]]; then
        # Check if fzf is available
        if ! command -v fzf >/dev/null 2>&1; then
            if [[ -n "$branch_name" ]]; then
                echo "Error: Worktree not found: $branch_name"
                echo "And fzf is not available for fuzzy selection"
            else
                echo "Error: fzf is required for interactive selection"
                echo "Please install fzf or provide a branch name"
            fi
            echo ""
            echo "Available worktrees:"
            git worktree list
            return 1
        fi

        # Prepare list for fzf with path:branch format for easy lookup
        local -a fzf_items
        for i in {1..${#worktree_branches[@]}}; do
            fzf_items+=("${worktree_paths[$i]}:${worktree_branches[$i]}")
        done

        # Use fzf to select
        local selected=$(printf "%s\n" "${fzf_items[@]}" | fzf \
            --height=40% \
            --reverse \
            --prompt="Select worktree: " \
            --preview='git -C $(echo {} | cut -d: -f1) log --oneline -n 10 2>/dev/null || echo "No commits"' \
            --preview-window=right:50%:wrap \
            --with-nth=2.. \
            --delimiter=: \
            --header="Jump to worktree")

        if [[ -z "$selected" ]]; then
            echo "No worktree selected"
            return 1
        fi

        # Extract path from selection
        worktree_path="${selected%%:*}"
    fi

    # Final validation
    if [[ ! -d "$worktree_path" ]]; then
        echo "Error: Worktree directory not found: $worktree_path"
        return 1
    fi

    # Jump to worktree
    cd "$worktree_path"
}

# ============================================================================
# ALIASES
# ============================================================================

# No aliases needed - functions have short names already
