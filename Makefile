# Переменные окружения для запуска контейнера
DB_USER=test_user
DB_PASSWORD=test_password
DB_NAME=test_db
CONTAINER_NAME=pg-test-container
IMAGE_NAME=pg-test
PORT=5432

# Пути для генератора датасетов
GEN_SCRIPT = tests/csv_generator/csv_generator.py
GEN_DIR = tests/csv_generator

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
		-v $(CURDIR)/tests/csv_generator:/tmp \
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

# Выполнить скрипт hll запроса (расширение)
sql-extern-hll-100:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/extern_hll_query_100.sql
sql-extern-hll-200:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/extern_hll_query_200.sql
sql-extern-hll-500:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/extern_hll_query_500.sql

# Нагрузочное тестирование (запуск в разных терминалах)
load-workers:
	docker exec -it pg-test-container fill_workers.sh $(or $(NUM_QUERIES),4) $(or $(DURATION),120)

sql-load-extern-hll-200:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/load_extern_hll_query.sql

sql-load-hll-200:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/load_HLL_query.sql

sql-load-extern-hll-500:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/load_extern_hll_query_500.sql

sql-load-hll-500:
	docker exec -i pg-test-container psql -U test_user -d test_db < tests/sql/load_HLL_query_500.sql

# Генерация датасетов
generate-100:
	python3 $(GEN_SCRIPT) 100000000 100000 365 $(GEN_DIR)/data_100.csv

generate-200:
	python3 $(GEN_SCRIPT) 200000000 60000000 1095 $(GEN_DIR)/data_200.csv

generate-500:
	python3 $(GEN_SCRIPT) 500000000 450000000 1825 $(GEN_DIR)/data_500.csv

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
