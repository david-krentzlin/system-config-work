install:
	@echo "Installing $(shell basename $(PWD))..."
	@command -v brew >/dev/null 2>&1 || (echo "Error: Homebrew not found. Install from https://brew.sh" && exit 1)
	@brew bundle --file=Brewfile
	@command -v mise >/dev/null 2>&1 || (echo "Error: mise not found. Install from https://mise.jdx.dev" && exit 1)
	@mise install
	@mise exec -- npm install -g yaml-language-server
	@mise exec -- gem install ruby-lsp solargraph
	@command -v cs >/dev/null 2>&1 || (echo "Error: coursier not found. Install coursier first." && exit 1)
	@command -v scalafmt >/dev/null 2>&1 || cs install scalafmt
	@GOBIN="$(HOME)/.local/bin" mise exec -- go install golang.org/x/tools/gopls@latest
	@mise exec -- rustup component add rust-analyzer

clean:
	@echo "Cleaning $(shell basename $(PWD))..."

.PHONY: install clean
