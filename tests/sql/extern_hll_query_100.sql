\timing on

-- Построение таблицы суточной агрегации
DROP TABLE IF EXISTS daily_uniques;
CREATE TABLE daily_uniques AS
SELECT viewed_at::date AS day,
       hll_add_agg(hll_hash_bigint(user_id::bigint), 12) AS users_hll
FROM user_logs
GROUP BY 1;

-- Проверка размера таблицы после построения
SELECT pg_size_pretty(pg_total_relation_size('daily_uniques')) AS daily_uniques_size;


EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '30 days')::date AND NOW()::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '30 days')::date AND NOW()::date;


EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '90 days')::date AND NOW()::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '90 days')::date AND NOW()::date;


EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '200 days')::date AND NOW()::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '200 days')::date AND NOW()::date;


EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '180 days' - INTERVAL '190 days')::date
                AND (NOW() - INTERVAL '180 days')::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '180 days' - INTERVAL '190 days')::date
                AND (NOW() - INTERVAL '180 days')::date;



-- 30 дней — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '30 days' AND NOW();

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '30 days' AND NOW();


-- 90 дней — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '90 days' AND NOW();

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '90 days' AND NOW();


-- 200 дней — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '200 days' AND NOW();

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '200 days' AND NOW();


-- "Последние полгода" — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '180 days' - INTERVAL '190 days'
                                  AND NOW() - INTERVAL '180 days';

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '180 days' - INTERVAL '190 days'
                                  AND NOW() - INTERVAL '180 days';