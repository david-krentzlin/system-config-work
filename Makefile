PKG :=
PACKAGES := $(shell find ./packages -maxdepth 1 -mindepth 1 -type d)

bootstrap:
	@sudo dnf install stow

install:
	@echo "Installing packages ..." 
	@for pkg_dir in $(PACKAGES); do \
		pkg_name=$$(basename $$pkg_dir); \
		echo " [ $$pkg_name ]"; \
		$(MAKE) -C $$pkg_dir install; \
	done

configure:
	@echo "Configuring packages ..."
	@for pkg_dir in $(PACKAGES); do \
		PKG_NAME=$$(basename $$pkg_dir); \
		echo " [ $$PKG_NAME ]"; \
		stow --target=$(HOME) --adopt --ignore 'Makefile|Ignored|Brewfile|Brewfile.lock' --dotfiles -d ./packages -S $$PKG_NAME; \
	done

clean:
	@echo "Installing packages for ..."
	@for pkg_dir in $(PACKAGES); do \
		PKG_NAME=$$(basename $$pkg_dir); \
		echo " [ $$PKG_NAME ]"; \
		$(MAKE) -C $$pkg_dir clean; \
	done
