# Переменные окружения для запуска контейнера
DB_USER=test_user
DB_PASSWORD=test_password
DB_NAME=test_db
CONTAINER_NAME=pg-test-container
IMAGE_NAME=pg-test
PORT=5432

.PHONY: build run connect sql-data stop clean restart rebuild

# Сборка чистого образа без секретов
build:
	docker build -t $(IMAGE_NAME) .

# Запуск контейнера с передачей ENV переменных
run:
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p $(PORT):5432 \
		-e POSTGRES_USER=$(DB_USER) \
		-e POSTGRES_PASSWORD=$(DB_PASSWORD) \
		-e POSTGRES_DB=$(DB_NAME) \
		$(IMAGE_NAME)

# Подключение к контейнеру
connect:
	docker exec -it $(CONTAINER_NAME) psql -U $(DB_USER) -d $(DB_NAME)

# Выполнить скрипт наполнения большим количеством данных
sql-data-100:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/big_data_100.sql
sql-data-200:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/big_data_200.sql
sql-data-500:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/big_data_500.sql

# Выполнить скрипт базового запроса
sql-count-500:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/count_query_500.sql
sql-count-200:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/count_query_200.sql
sql-count-100:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/count_query_100.sql

# Выполнить скрипт hll запроса
sql-hll-500:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/HLL_query_500.sql
sql-hll-200:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/HLL_query_200.sql
sql-hll-100:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/HLL_query_100.sql

# Остановить контейнер
stop:
	docker stop $(CONTAINER_NAME) || true

# Запустить контейнер
start:
	docker start $(CONTAINER_NAME)

# Удалить контейнер
clean: stop
	docker rm $(CONTAINER_NAME) || true

# Перезапуск (очистка и новый запуск)
restart: clean run

# Пересборка контейнера (очистка, новая сборка и запуск)
rebuild: clean build run
