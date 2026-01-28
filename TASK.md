
# Goal

Establish a terminal based development environment that embraces consistency and requires little maintenance.
I have an elaborate emacs setup that allows me to develop all sorts of projects in my day-to-day job as a software engineer.
I want to start an experiment to see how much of that I can turn into a configuration using modern command line tools. 
I want a fast and low friction way to do software development.
The goal is to provide a set of configurations that set up this environment and makes sure it works well for the described languages and workflows.


# Rules

* You MUST consult the documentation provided in the reference section late.
* YOU SHALL provide suggestions on tools that I am not aware of that might be a better fit
* YOU MUST NEVER make up any configuration setting. All settings have to be available and documentated

# Task

This project is my personal configuration management repository.
Each component has its own directory with a Makefile and its config content.
I use stow to do the synchronization. I configured stow to translate dot-file to .file.

I want you to add the required configuration to configure the most important components of my  development environment using modern terminal based tooling.

1. Make sure wezterm is configured so that I can use separate sessions easily and I can manage split panes and zooming comfortably as well as navigating between those (this will be a major part of my work)
2. Make sure helix is configured and optimized for the following languages (ruby, html, css, go, rust, scala, csv, json, yaml, helm templats, hocon config, erb, markdown, mermaid, asciidoc). Make sure the makefile for the component contains all the required installations of language servers, formatters etc. Please ask if you're unsure which formatter to use.
3. Make sure lazygit is configured so that I can use it comfortably alongside helix for a smooth git management experience
4. Make sure helix is configured to support spellchecking in my comments / documents

# Facts

* This is a macos machine
* I use homebrew to manage packages

# Details

* you MUST make sure that keybidings between helix and wezterm, and lazygit and wezterm don't conflict. I want to be able to use this comfortably
* you MUST make sure I can easily copy from helix to the system clipboard and back
* you MUST make sure to use the terminus nerdfont for everything
* I want modus themes to be applied consistently. If the components don't support it out of the box, please configure colors according to modus-vivendi


# Important workflows

* Project selection: Select a predefined project (maybe via zoxid, or wezeterm session or fzf) and jump into the directory (session isolation in terminal is preferred so I can switch between sessions)
* Git: I want to be able to quickly fire up a split pane in the current project root with lazygit running where I can interact (easy way to close it again is also required)


# References
* lazygit https://github.com/jesseduffield/lazygit
* helix https://docs.helix-editor.com/
* wezterm https://wezterm.org/config/files.html

# Progress

## Done
* WezTerm sessions/panes/zoom/navigation configured with CTRL-t leader and non-conflicting bindings.
* WezTerm uses Modus Vivendi colors and Terminus Nerd Font (Terminess) with launcher access.
* Git workflow: CTRL-t g opens lazygit in a split pane at the project root; CTRL-t x closes panes.
* Helix uses Modus Vivendi (custom theme) and system clipboard integration.
* Helix spellcheck wired via ltex-ls for Markdown and AsciiDoc.
* Lazygit installed via mise and wired for the wezterm split pane workflow.
* Tooling installs wired via per-package Makefiles, with mise global defaults.
* WezTerm project picker launches zoxide + fzf and spawns a workspace.

## Partially done / needs refinement
* Helix language tooling lacks formatter/LSP choices for CSV, HOCON, ERB, Mermaid.
* Helix toolchain setup via mise needs verification (scalafmt via coursier, gopls via go install, rust-analyzer via rustup).

## Not done
* Choose formatters/LSPs for CSV, HOCON, ERB, Mermaid and wire installs.
