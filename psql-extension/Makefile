EXTENSION = sliding_hll
DATA = sliding_hll--1.0.sql

# 1. Указываем точное имя скрытой папки. 
# Судя по скриншоту, она начинается на "SlidingHyperL..." 
# Вставьте её точное имя вместо "SlidingHyperLogLog-API" ниже:
API_DIR = SlidingHyperLogLog-API

# 2. Объектные файлы, которые нужно собрать.
# Указываем путь к исходнику .cpp внутри локальной папки src
OBJS = pg_sliding_hll.o $(API_DIR)/src/SlidingHyperLogLog.o

# 3. Флаги препрецессора, которые увидит JIT-компилятор clang-17.
# Переводим путь к локальной папке include в каноничный абсолютный формат
PG_CPPFLAGS = -I$(abspath ./$(API_DIR)/include)

# 4. Флаги стандартного компилятора
PG_CXXFLAGS = -std=c++20 -O3

# Инфраструктура PGXS PostgreSQL
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
