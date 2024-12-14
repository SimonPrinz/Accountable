DC = docker compose
EXEC = $(DC) exec -it app

start:
	$(DC) up -d
stop:
	$(DC) down
restart: stop start
clean:
	$(DC) down -v --rmi all
	rm -rf var/ vendor/ node_modules/

composer-install: start
	$(EXEC) git config --global --add safe.directory /app
	$(EXEC) composer install
npm-install: start
	$(EXEC) npm install

composer-test: start
	$(EXEC) composer run test
composer-phpstan: start
	$(EXEC) composer run phpstan

npm-build: start
	$(EXEC) npm run dev
npm-watch: start
	$(EXEC) npm run watch

exec: start
	$(EXEC) bash
cache-clear: start
	$(EXEC) console cache:clear
	$(EXEC) console cache:pool:clear --all

setup: composer-install npm-install npm-build database-recreate bucket-create cache-clear
database-recreate: start
	$(EXEC) console doctrine:database:drop --force || true
	$(EXEC) console doctrine:database:create
	$(EXEC) console doctrine:migration:migrate -q
bucket-create: start
	$(DC) exec files sh -c 'mc alias set local http://localhost:9000 root toorToor'
	$(DC) exec files sh -c 'mc mb -p local/files'
	$(DC) exec files sh -c 'mc anonymous set download local/files'

rebuild: stop
	$(DC) build --pull --no-cache
	$(MAKE) start
