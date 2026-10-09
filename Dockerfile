FROM postgres:16

COPY psql-extension/ /tmp/psql-extension/

# Используем pg_config, чтобы автоматически определить пути и скопировать файлы
RUN cp /tmp/psql-extension/*.control $(pg_config --sharedir)/extension/ && \
    cp /tmp/psql-extension/*.sql $(pg_config --sharedir)/extension/ && \
    cp /tmp/psql-extension/*.so $(pg_config --pkglibdir)/ && \
    rm -rf /tmp/psql-extension/

COPY tests/csv_generator/data_500.csv /tmp/data.csv

EXPOSE 5432