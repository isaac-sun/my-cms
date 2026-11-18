# 读取 .env 并导出给所有子命令（go run / goose / node 都能拿到这些环境变量）
include .env
export

.PHONY: up down ps logs user bff health test proto migrate-up migrate-down migrate-status

# ---- 基础设施（Docker）----
up:
	docker compose -f deploy/docker-compose.yml --env-file .env up -d --wait
down:
	docker compose -f deploy/docker-compose.yml --env-file .env down
ps:
	docker compose -f deploy/docker-compose.yml --env-file .env ps
logs:
	docker compose -f deploy/docker-compose.yml --env-file .env logs -f

# ---- 数据库迁移（goose）----
migrate-up:
	goose -dir services/user/migrations postgres "$(DATABASE_URL)" up
migrate-down:
	goose -dir services/user/migrations postgres "$(DATABASE_URL)" down
migrate-status:
	goose -dir services/user/migrations postgres "$(DATABASE_URL)" status

# ---- 代码生成 ----
proto:
	buf lint && buf generate

# ---- 应用服务（各开一个终端）----
user:
	cd services/user && go run ./cmd/server
bff:
	cd bff && npm run dev
test:
	cd services/user && go test ./...

health:
	curl -s localhost:3000/api/health; echo