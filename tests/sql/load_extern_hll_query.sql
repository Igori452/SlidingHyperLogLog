-- SET max_parallel_workers_per_gather = 0;

EXPLAIN (ANALYZE, BUFFERS)
SELECT hll_cardinality(hll_add_agg(hll_hash_bigint(user_id::bigint), 12))
FROM user_logs
WHERE viewed_at::timestamptz BETWEEN NOW() - INTERVAL '365 days' AND NOW();