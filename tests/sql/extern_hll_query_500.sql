\timing on

-- SET max_parallel_workers_per_gather = 0;

-- Построение таблицы суточной агрегации
DROP TABLE IF EXISTS daily_uniques;
CREATE TABLE daily_uniques AS
SELECT viewed_at::date AS day,
       hll_add_agg(hll_hash_bigint(user_id::bigint), 12) AS users_hll
FROM user_logs
GROUP BY 1;
SELECT pg_size_pretty(pg_total_relation_size('daily_uniques')) AS daily_uniques_size;


-- 1 год — запрос к агрегации
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '365 days')::date AND NOW()::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '365 days')::date AND NOW()::date;


-- 2 года — запрос к агрегации
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '730 days')::date AND NOW()::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '730 days')::date AND NOW()::date;


-- 4 года — запрос к агрегации
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '1460 days')::date AND NOW()::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '1460 days')::date AND NOW()::date;


-- 2 года, закончившихся 1 год назад — запрос к агрегации
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '365 days' - INTERVAL '730 days')::date
                AND (NOW() - INTERVAL '365 days')::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '365 days' - INTERVAL '730 days')::date
                AND (NOW() - INTERVAL '365 days')::date;


-- Первый год — запрос к агрегации
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '1460 days' - INTERVAL '365 days')::date
                AND (NOW() - INTERVAL '1460 days')::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '1460 days' - INTERVAL '365 days')::date
                AND (NOW() - INTERVAL '1460 days')::date;



-- 1 год — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' AND NOW();

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' AND NOW();


-- 2 года — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '730 days' AND NOW();

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '730 days' AND NOW();


-- 4 года — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '1460 days' AND NOW();

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '1460 days' AND NOW();


-- 2 года, закончившихся 1 год назад — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' - INTERVAL '730 days'
                                  AND NOW() - INTERVAL '365 days';

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' - INTERVAL '730 days'
                                  AND NOW() - INTERVAL '365 days';


-- Первый год — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '1460 days' - INTERVAL '365 days'
                                  AND NOW() - INTERVAL '1460 days';

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '1460 days' - INTERVAL '365 days'
                                  AND NOW() - INTERVAL '1460 days';