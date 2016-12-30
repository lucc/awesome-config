install-deps:
	pacaur -S ttf-font-awesome dictd
	$(MAKE) -C ~/src/shell dict-pager.sh
