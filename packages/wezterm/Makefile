install:
	@echo "Installing $(shell basename $(PWD))..."
	@command -v brew >/dev/null 2>&1 || (echo "Error: Homebrew not found. Install from https://brew.sh" && exit 1)
	@brew bundle --file=Brewfile

clean:
	@echo "Cleaning $(shell basename $(PWD))..."

.PHONY: install clean
