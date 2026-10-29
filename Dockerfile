FROM postgres:16 AS hll-builder

# Установка инструментов сборки и заголовочных файлов
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        postgresql-server-dev-16 \
        ca-certificates \
        git \
    && rm -rf /var/lib/apt/lists/*

# Клонирование и компиляция postgresql-hll
RUN git clone --depth 1 https://github.com/citusdata/postgresql-hll.git /tmp/postgresql-hll \
    && cd /tmp/postgresql-hll \
    && make \
    && make install

FROM postgres:16

# Копирование собранных артефактов HLL из этапа сборки
COPY --from=hll-builder /usr/share/postgresql/16/extension/hll.control /usr/share/postgresql/16/extension/
COPY --from=hll-builder /usr/share/postgresql/16/extension/hll--*.sql /usr/share/postgresql/16/extension/
COPY --from=hll-builder /usr/lib/postgresql/16/lib/hll.so /usr/lib/postgresql/16/lib/

# Копирование файлов расширения (control, sql, so)
COPY psql-extension/ /tmp/psql-extension/
RUN cp /tmp/psql-extension/*.control $(pg_config --sharedir)/extension/ && \
    cp /tmp/psql-extension/*.sql $(pg_config --sharedir)/extension/ && \
    cp /tmp/psql-extension/*.so $(pg_config --pkglibdir)/ && \
    rm -rf /tmp/psql-extension/

# Копирование скрипта для заполнения пула воркеров и выдача прав на исполнение
COPY tests/sql/fill_workers.sh /usr/local/bin/fill_workers.sh
RUN chmod +x /usr/local/bin/fill_workers.sh

EXPOSE 5432
