# ---------- required environment ----------
ifndef STAGE
$(error STAGE environment variable is not set. Example: STAGE=dev make deploy)
endif

# ---------- validation ----------
VALID_STAGES := dev prod

ifeq ($(filter $(STAGE),$(VALID_STAGES)),)
$(error Invalid STAGE "$(STAGE)". Must be one of: $(VALID_STAGES))
endif

COMPOSE_STAGE_FILE := docker-compose.$(STAGE).yml

ifeq ($(wildcard $(COMPOSE_STAGE_FILE)),)
$(error Missing $(COMPOSE_STAGE_FILE))
endif

# Directory containing stage-specific envs
STAGE_ENVS_DIR := ./stages/$(STAGE)/envs

ENV_FILES := $(wildcard $(STAGE_ENVS_DIR)/*.env)
# Automatically find all .env files in that directory
$(info Loading env files from $(STAGE_ENVS_DIR):)
$(foreach f,$(ENV_FILES),$(info  - $(f)))

# ---------- optional env file ----------
ifeq ($(strip $(SECRET_ENV_FILE)),)
SECRET_ENV_FILE := /opt/docker-secrets/docker-secrets.env
endif
ifneq ($(wildcard $(SECRET_ENV_FILE)),)
ENV_FILES := $(ENV_FILES) $(SECRET_ENV_FILE)
else
$(warning SECRET_ENV_FILE "$(SECRET_ENV_FILE)" not found, skipping)
endif

# Construct Docker Compose flags
ENV_FILE_FLAGS := $(foreach f,$(ENV_FILES),--env-file "$(f)") $(SECRET_ENV_FILE_FLAG)

# ---------- docker compose ----------
DC_CORE = docker compose \
  $(ENV_FILE_FLAGS) \
  -f docker-compose.yml \
  -f $(COMPOSE_STAGE_FILE)

DC_APPS = docker compose \
  $(ENV_FILE_FLAGS) \
  -f docker-compose.yml \
  -f $(COMPOSE_STAGE_FILE) \
  -f docker-compose.applications.yml

ENV_FILES_ABS := $(abspath $(ENV_FILES))
ENV_FILES_ABS_QUOTED := $(foreach f,$(ENV_FILES_ABS),"$(f)")
WAIT_KEYCLOAK_SCRIPT ?= $(CURDIR)/services/auth/identity/wait_for_keycloak.sh

# ---------- targets ----------
.PHONY: help deploy up up-core up-apps wait-keycloak down destroy restart logs logs-core logs-apps

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

deploy: up-core wait-keycloak down up-apps ## Phase 1 -> 2 -> 3 deployment
up: deploy ## Alias for deploy
up-core: ## Phase 1: start core services (traefik/keycloak/etc.)
	$(DC_CORE) up -d

wait-keycloak: ## Wait until Keycloak is reachable/ready
	$(MAKE) up-core
	test -f "$(WAIT_KEYCLOAK_SCRIPT)"
	bash "$(WAIT_KEYCLOAK_SCRIPT)" $(ENV_FILES_ABS_QUOTED)

up-apps: ## Phase 3: start services that depend on Keycloak resources
	$(DC_APPS) up -d

down: ## Stop containers
	$(DC_APPS) down --remove-orphans

destroy: ## Stop containers and remove volumes
	docker container prune -f
	$(DC_APPS) down -v --remove-orphans

restart: ## Restart full stack (down + deploy)
	$(MAKE) down
	$(MAKE) deploy

images:  ## Rebuild all images
	$(DC_CORE) build
	$(DC_APPS) build

remake: destroy images up ## Completely remake the stack

logs: ## Follow logs for full stack
	$(DC_APPS) logs -f

logs-core: ## Follow logs for core services only
	$(DC_CORE) logs -f

logs-apps: ## Follow logs for apps/services only
	$(DC_APPS) logs -f