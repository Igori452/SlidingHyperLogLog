#!/bin/bash
NUM_QUERIES=${1:-4}
DB_USER="test_user"
DB_NAME="test_db"

echo "Запускаю $NUM_QUERIES параллельных процессов (Ctrl+C для остановки)..."

for i in $(seq 1 $NUM_QUERIES); do
    (
        while true; do
            psql -U "$DB_USER" -d "$DB_NAME" -c "
                SELECT count(*) FROM user_logs
                WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' AND NOW();
            " > /dev/null 2>&1
        done
    ) &
    echo "  Процесс $i запущен (PID: $!)"
done

echo "Все процессы запущены. Нажмите Ctrl+C, чтобы остановить."
wait