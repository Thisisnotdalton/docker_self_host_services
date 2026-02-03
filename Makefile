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

# ---------- targets ----------
.PHONY: deploy up up-core up-apps wait-keycloak tofu-apply down destroy restart logs logs-core logs-apps

# Full 3-phase deployment
deploy: up-core tofu-apply up-apps

# Backwards-compatible: keep `up` as the full deploy
up: deploy

# Phase 1: bring up only the core services (traefik/keycloak/etc.)
up-core:
	$(DC_CORE) up -d

wait-keycloak:
	./services/auth/identity/wait_for_keycloak.sh

# Phase 2: apply Keycloak configuration (realm/clients) using OpenTofu
tofu-apply: wait-keycloak
	$(TOFU)

# Phase 3: bring up services that depend on Keycloak resources (oauth2-proxy/apps)
up-apps:
	$(DC_APPS) up -d

down:
	$(DC_APPS) down

destroy:
	$(DC_APPS) down -v

restart:
	$(MAKE) down
	$(MAKE) deploy

logs:
	$(DC_APPS) logs -f

logs-core:
	$(DC_CORE) logs -f

logs-apps:
	$(DC_APPS) logs -f