
.PHONY: README.md
README.md:
	terraform-docs md -c .terraform-docs.yml . > README.md
