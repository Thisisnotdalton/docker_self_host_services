# ---------- required environment ----------
ifndef STAGE
$(error STAGE environment variable is not set. Example: STAGE=dev make up)
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
DC = docker compose \
  -f docker-compose.yml \
  -f $(COMPOSE_STAGE_FILE)

# ---------- targets ----------
.PHONY: up down destroy restart logs

up:
	$(DC) up -d

down:
	$(DC) down

destroy:
	$(DC) down -v

restart:
	$(DC) down
	$(DC) up -d

logs:
	$(DC) logs -f