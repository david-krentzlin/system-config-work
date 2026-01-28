install:
	@echo "Installing $(shell basename $(PWD))..."
	@command -v mise >/dev/null 2>&1 || (echo "Error: mise not found. Install from https://mise.jdx.dev" && exit 1)
	@mise install lazygit

clean:
	@echo "Cleaning $(shell basename $(PWD))..."

.PHONY: install clean
