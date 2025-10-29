SHELL             := /bin/bash
VENV              := .venv
PYTHON            := $(VENV)/bin/python
PIP               := $(VENV)/bin/pip
PIP_COMPILE       := $(VENV)/bin/pip-compile
PIP_SYNC          := $(VENV)/bin/pip-sync
DEV_REQ_IN_FILE   := dev.requirements.in
DEV_REQ_OUT_FILE  := dev.requirements.txt
DEFAULT_REQ       := pip==25.2 pip-tools
ANSIBLE_REQ       := ansible ansible-lint molecule
MKDOCS_MATERIAL   := mkdocs-material

BLACK   := \033[30m
RED     := \033[31m
GREEN   := \033[32m
YELLOW  := \033[33m
BLUE    := \033[34m
PURPLE  := \033[35m
CYAN    := \033[36m
WHITE   := \033[37m

BOLD          := \033[1m
BOLD_OFF      := \033[22m
ITALIC        := \033[3m
ITALIC_OFF    := \033[23m
UNDERLINE     := \033[4m
UNDERLINE_OFF := \033[24m
DIM           := \033[2m
RESET         := \033[0m

.PHONY: init upgrade clean init-ansible init-mkdocs-material

define message_generate_requirements_file
	printf "→ Generating %s development requirements file... " "$(1)"
endef

define message_create_venv
	printf "→ Creating virtual environment in %s... "  "$(1)"
endef

define message_install_requirements
	printf "→ Installing %s requirements... " "$(1)"
endef

define message_venv_exist
	printf "Virtual environment %s already exist\n" "$(1)"
endef

define message_venv_not_found
	printf "→ Virtual environment %s not found\n" "$(1)"
endef

define message_file_not_found
	printf "→ %s file not found\n" "$(1)"
endef

define message_check_dependency_updates
	printf "→ Checking for dependency updates... "
endef

define message_install_dependency_updates
	printf "→ Installing dependency updates into %s... " "$(1)"
endef

define message_remove_venv
	printf "→ Removing %s virtual environment... " "$(1)"
endef

define message_remove_requirements_files
	printf "→ Removing development requirements files... "
endef

define message_remove_requirements_files_not_found
	printf "→ Development requirements files not found\n"
endef

define message_success
	printf "$(GREEN)done$(RESET)\n"
endef

define create_venv
	python3 -m venv "$(1)"
endef

define install_requirements
	$(PIP) install -r "$(1)" --quiet
endef

define check_dependency_updates
	$(PIP_COMPILE) \
		--upgrade \
		--quiet \
		--no-header \
		--no-annotate \
		--strip-extras \
		--allow-unsafe \
		--output-file $(1) \
		$(2)
endef

define install_dependency_updates
	$(PIP_SYNC) $(1) --quiet
endef

define remove_venv
	rm -rf "$(1)"
endef

define remove_development_requirements_files
	rm -f "$(1)" "$(2)"
endef

init:
	@if [ ! -d "$(VENV)" ]; \
		then \
		$(call message_generate_requirements_file,default); \
		> $(DEV_REQ_IN_FILE); \
		for package in $(DEFAULT_REQ); do \
			echo $$package >> $(DEV_REQ_IN_FILE); \
		done; \
		$(call message_success); \
		$(call message_create_venv,$(VENV)); \
		$(call create_venv,$(VENV)) && \
		$(call message_success); \
		$(call message_install_requirements,default); \
		$(call install_requirements,$(DEV_REQ_IN_FILE)) && \
		$(call message_success); \
	else \
		$(call message_venv_exist,$(VENV)); \
	fi

init-ansible:
	@if [ ! -d "$(VENV)" ]; \
		then \
		$(call message_generate_requirements_file,Ansible); \
		> $(DEV_REQ_IN_FILE); \
		for package in $(DEFAULT_REQ) $(ANSIBLE_REQ); do \
			echo $$package >> $(DEV_REQ_IN_FILE); \
		done; \
		$(call message_success); \
		$(call message_create_venv,$(VENV)); \
		$(call create_venv,$(VENV)) && \
		$(call message_success); \
		$(call message_install_requirements,Ansible); \
		$(call install_requirements,$(DEV_REQ_IN_FILE)) && \
		$(call message_success); \
	else \
		$(call message_venv_exist); \
	fi

init-mkdocs-material:
	@if [ ! -d "$(VENV)" ]; \
		then \
		$(call message_generate_requirements_file,Material for MkDocs); \
		> $(DEV_REQ_IN_FILE); \
		for package in $(DEFAULT_REQ) $(MKDOCS_MATERIAL); do \
			echo $$package >> $(DEV_REQ_IN_FILE); \
		done; \
		$(call message_success); \
		$(call message_create_venv); \
		$(call create_venv,$(VENV)) && \
		$(call message_success); \
		$(call message_install_requirements,Material for MkDocs); \
		$(call install_requirements,$(DEV_REQ_IN_FILE)) && \
		$(call message_success); \
	else \
		$(call message_venv_exist); \
	fi

upgrade:
	@if [ ! -d "$(VENV)" ]; \
	then \
    $(call message_venv_not_found); \
	elif [ ! -f "$(DEV_REQ_IN_FILE)" ]; \
	then \
	$(call message_file_not_found,$(DEV_REQ_IN_FILE)); \
	else \
		$(call message_check_dependency_updates); \
		$(call check_dependency_updates,$(DEV_REQ_OUT_FILE),$(DEV_REQ_IN_FILE)) && \
		$(call message_success); \
		$(call message_install_dependency_updates,$(VENV)); \
		$(call install_dependency_updates,$(DEV_REQ_OUT_FILE)) && \
		$(call message_success); \
	fi

clean:
	@if [ -d "$(VENV)" ]; \
	then \
		$(call message_remove_venv,$(VENV)); \
		$(call remove_venv,$(VENV)); \
		$(call message_success); \
	else \
		$(call message_venv_not_found,$(VENV)); \
	fi; \
	if [ -f "$(DEV_REQ_IN_FILE)" ] || [ -f "$(DEV_REQ_OUT_FILE)" ]; \
	then \
		$(call message_remove_requirements_files); \
		$(call remove_development_requirements_files,$(DEV_REQ_IN_FILE),$(DEV_REQ_OUT_FILE)); \
		$(call message_success); \
	else \
		$(call message_remove_requirements_files_not_found); \
	fi
