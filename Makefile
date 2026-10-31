.PHONY: lint
lint:
	bash -n apply.sh
	bash -n scripts/xremap-apply.sh
