.PHONY: help build migrate-status migrate-up migrate-down migrate-create clean test docker-build docker-up docker-down docker-shell docker-dev

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

build: ## Build the migration tool
	@cd migrations && go build -o migrate .
	@echo "✓ Migration tool built"

migrate-status: ## Show migration status
	@./migrate.sh status

migrate-up: ## Apply pending migrations
	@./migrate.sh up

migrate-down: ## Rollback last migration
	@./migrate.sh down

migrate-create: ## Create new migration (usage: make migrate-create NAME=my_migration)
	@if [ -z "$(NAME)" ]; then \
		echo "Error: NAME is required. Usage: make migrate-create NAME=my_migration"; \
		exit 1; \
	fi
	@./migrate.sh create $(NAME)

init: ## Initialize Terraform
	@terraform init

plan: ## Run terraform plan
	@terraform plan

apply: ## Run terraform apply
	@terraform apply

clean: ## Remove built binaries and temporary files
	@rm -f migrations/migrate

	@rm -f terraform.tfstate.backup_*
	@echo "✓ Cleaned up"

test: build ## Build and test the migration tool
	@./migrate.sh status
	@echo "✓ Migration tool is working"

# Docker targets
docker-build: ## Build Docker images
	@docker compose build

docker-up: ## Start Docker containers
	@docker compose up -d terraform

docker-down: ## Stop Docker containers
	@docker compose down

docker-shell: ## Open shell in Terraform container
	@docker compose run --rm terraform

docker-dev: ## Start development container
	@docker compose up -d terraform-dev
	@docker compose exec terraform-dev

docker-terraform: ## Run terraform command in container (usage: make docker-terraform CMD="plan")
	@docker compose run --rm terraform terraform $(CMD)

docker-migrate: ## Run migration command in container (usage: make docker-migrate CMD="status")
	@docker compose run --rm migrate ./migrate.sh $(CMD)

docker-clean: ## Clean up Docker resources
	@docker compose down -v
	@docker system prune -f

.DEFAULT_GOAL := help
