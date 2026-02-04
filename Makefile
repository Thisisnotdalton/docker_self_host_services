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

# ---------- docker compose ----------
DC_CORE = docker compose \
  -f docker-compose.yml \
  -f $(COMPOSE_STAGE_FILE)

DC_APPS = docker compose \
  -f docker-compose.yml \
  -f $(COMPOSE_STAGE_FILE) \
  -f docker-compose.applications.yml

# ---------- OpenTofu ----------
# Option A (recommended): run tofu via a dedicated compose service (e.g., in docker-compose.tofu.yml)
#   TOFU = docker compose -f docker-compose.tofu.yml -f $(COMPOSE_STAGE_FILE) run --rm tofu
# Option B: run tofu directly as a container (fill in image/mounts as you implement it)
TOFU ?= echo "TOFU runner not configured. Set TOFU=... (see Makefile) && false"

WAIT_KEYCLOAK_SCRIPT ?= $(CURDIR)/services/auth/identity/wait_for_keycloak.sh

# ---------- targets ----------
.PHONY: help deploy up up-core up-apps wait-keycloak tofu-apply down destroy restart logs logs-core logs-apps

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

deploy: up-core tofu-apply up-apps ## Phase 1 -> 2 -> 3 deployment
up: deploy ## Alias for deploy
up-core: ## Phase 1: start core services (traefik/keycloak/etc.)
	$(DC_CORE) up -d

wait-keycloak: ## Wait until Keycloak is reachable/ready
	test -f "$(WAIT_KEYCLOAK_SCRIPT)"
	bash "$(WAIT_KEYCLOAK_SCRIPT)"

tofu-apply: wait-keycloak ## Phase 2: apply Keycloak resources with OpenTofu
	$(TOFU)

up-apps: ## Phase 3: start services that depend on Keycloak resources
	$(DC_APPS) up -d

down: ## Stop containers
	$(DC_APPS) down --remove-orphans

destroy: ## Stop containers and remove volumes
	$(DC_APPS) down -v --remove-orphans

restart: ## Restart full stack (down + deploy)
	$(MAKE) down
	$(MAKE) deploy

logs: ## Follow logs for full stack
	$(DC_APPS) logs -f

logs-core: ## Follow logs for core services only
	$(DC_CORE) logs -f

logs-apps: ## Follow logs for apps/services only
	$(DC_APPS) logs -f