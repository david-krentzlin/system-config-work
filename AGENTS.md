# AGENTS

This file is guidance for agentic coding assistants working in this repo.
It captures how to build, test, and keep the dotfiles consistent.

Repository overview
- This is a dotfiles repo organized under packages/<name>.
- Each package is stowed into $HOME via the root Makefile.
- Most logic lives in config files (Lua, TOML, shell, Makefile).
- There is no application runtime or compiled artifacts here.

File layout notes
- Stow targets are in packages/<name>/dot-* paths.
- Dotfile names mirror the final destination (dot-config, dot-ssh).
- Keep per-tool config isolated to its package directory.
- Avoid cross-package edits unless needed for a shared workflow.
- Do not rename files or directories unless explicitly requested.

Cursor/Copilot rules
- No .cursor/rules/, .cursorrules, or .github/copilot-instructions.md found.

Build, lint, and test commands
- Root install: make install
- Root configure (stow): make configure
- Root clean: make clean
- Package install: make -C packages/<package> install
- Package clean: make -C packages/<package> clean

Test guidance
- No automated tests are present in this repo.
- There are no single-test commands to run.
- Validate changes manually by reloading the target app (e.g. WezTerm).

Lint/format guidance
- No lint or formatter tasks are defined in Makefiles.
- Preserve existing formatting and ordering within each file.
- Do not auto-format unless the repo adds a formatter.
- Keep alignment consistent within a block (tables, arrays, maps).
- Use existing comment style rather than introducing new patterns.

Code style guidelines (general)
- Prefer minimal, local changes and avoid touching unrelated files.
- Keep changes focused and consistent with existing patterns.
- Use ASCII only unless the file already uses Unicode.
- Avoid trailing whitespace and keep blank lines intentional.
- Keep comments short and only add them when needed for clarity.

Lua (wezterm and other Lua configs)
- Follow existing patterns in wezterm.lua.
- Use local bindings at top: local wezterm = require "wezterm".
- Prefer local helpers (e.g. trim_whitespace) over inline code.
- Use snake_case for local functions.
- Guard against nil values and empty strings.
- Use wezterm.log_error or wezterm.log_info for diagnostics.
- When spawning commands, use zsh -lic for login env.
- Keep tables aligned with the file's current indentation style.
- Prefer wezterm.action_callback for user-driven prompts.
- Use wezterm.mux APIs when creating workspaces or windows.

TOML (yazi, helix, starship, mise)
- Keep section order stable and grouped by feature.
- Use double quotes for strings.
- Use inline tables only where already used.
- Keep array values on a single line unless very long.
- Prefer descriptive comments above a block, not inline.
- Keep key casing consistent with the tool's schema.
- Use explicit open rules instead of implicit defaults.

Tool-specific expectations
- WezTerm: keep keybindings in config.keys with existing modifier scheme.
- WezTerm: prefer spawn = { cwd = ... } for workspace-aware windows.
- Yazi: keep opener definitions grouped and ordered by intent.
- Yazi: ensure open rules include a fallback for "*".
- Helix: keep theme settings in the custom theme file.
- Helix: languages.toml should stay grouped by language.
- Starship: preserve prompt module ordering and spacing.
- Mise: keep tool versions grouped by language/runtime.

Makefiles
- Use tabs for recipe lines.
- Keep targets simple and consistent with current ones.
- Keep .PHONY up to date when adding targets.
- Avoid complex shell logic unless necessary.

Shell snippets (zsh, sh)
- Use command -v to check for dependencies.
- Print clear error messages and exit non-zero on failure.
- Quote variables when used in paths.
- Prefer exec to replace shells when launching tools.
- Avoid non-portable flags unless the script is OS-specific.
- Keep scripts idempotent and safe to re-run.

Naming conventions
- Functions: snake_case in Lua.
- Variables: lower_snake_case in Lua and shell.
- Keys: keep the casing already used by the config format.
- Filenames: do not rename unless explicitly requested.
- Keybindings: align with the existing modifier scheme.
- Workspace names: derive from directory names when possible.

Error handling expectations
- Avoid hard failures in interactive configs.
- If a command may be missing, check before running it.
- Log errors and return early instead of throwing.
- Prefer safe defaults over failing on empty input.
- Use fallback shells when launching external tools fails.
- Avoid blocking prompts unless the action is user-initiated.

Workspace conventions
- Stow targets come from packages/<name>/dot-*
- Keep per-tool configs in their existing package.
- Avoid cross-package changes without strong justification.
- Prefer workspace-aware commands (cwd) when spawning programs.
- Keep workspace switching behavior consistent with current UX.

Committing changes (binding rules)
- DON'T stage (DON'T git add) unless explicitly instructed.
- DON'T commit unless explicitly instructed.
- DO suggest a commit message when you finish.
- Consider ALL changes in git diff and git diff --cached.

Commit message format (binding rules)
- All commit messages must start with [AI].
- Use Conventional Commits format.
- Body is optional; wrap at 72 chars if used.
- Explain why this approach is chosen, not a file list.
- Do not use markdown syntax in the commit message.

Pull request rules (binding rules)
- PRs must be focused and minimal.
- PRs must include tests when behavior changes.
- PRs must be mergeable and stand alone.

Common manual checks
- WezTerm: reload config (CMD+SHIFT+R) after edits.
- Yazi: reopen or reload config, verify open/edit actions.
- Stow: re-run make configure if file placement changes.
- Helix: restart editor or reload config to verify themes.
- Starship: open a new shell to confirm prompt changes.
- Aerospace: reload configuration from the app menu.

When in doubt
- Read surrounding config for patterns before editing.
- Ask only when the change could alter behavior materially.
- Prefer the least surprising change for interactive tools.
