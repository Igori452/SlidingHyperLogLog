EXTENSION   = sliding_hll
MODULE_big  = sliding_hll
OBJS        = pg_sliding_hll.o SlidingHyperLogLog-API/src/SlidingHyperLogLog.o
DATA        = sliding_hll--1.0.sql

PG_CPPFLAGS = -I$(CURDIR)/SlidingHyperLogLog-API/include -I$(shell pg_config --includedir-server) -std=c++20
PG_CXXFLAGS = -std=c++20 -O3

PG_CONFIG   = pg_config
PGXS       := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)