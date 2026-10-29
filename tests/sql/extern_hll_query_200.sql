\timing on

-- Построение таблицы суточной агрегации
DROP TABLE IF EXISTS daily_uniques;
CREATE TABLE daily_uniques AS
SELECT viewed_at::date AS day,
       hll_add_agg(hll_hash_bigint(user_id::bigint), 12) AS users_hll
FROM user_logs
GROUP BY 1;
SELECT pg_size_pretty(pg_total_relation_size('daily_uniques')) AS daily_uniques_size;


EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '180 days')::date AND NOW()::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '180 days')::date AND NOW()::date;


EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '365 days')::date AND NOW()::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '365 days')::date AND NOW()::date;


EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '730 days')::date AND NOW()::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '730 days')::date AND NOW()::date;


EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '365 days' - INTERVAL '730 days')::date
                AND (NOW() - INTERVAL '365 days')::date;

SELECT hll_cardinality(hll_union_agg(users_hll))
FROM daily_uniques
WHERE day BETWEEN (NOW() - INTERVAL '365 days' - INTERVAL '730 days')::date
                AND (NOW() - INTERVAL '365 days')::date;



-- 180 дней — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '180 days' AND NOW();

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '180 days' AND NOW();


-- 365 дней — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' AND NOW();

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' AND NOW();


-- 730 дней — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '730 days' AND NOW();

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '730 days' AND NOW();


-- 730 дней, окончание 365 дней назад — вычисление на лету
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' - INTERVAL '730 days'
                                  AND NOW() - INTERVAL '365 days';

SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' - INTERVAL '730 days'
                                  AND NOW() - INTERVAL '365 days';