-- SET max_parallel_workers_per_gather = 0;

EXPLAIN (ANALYZE, BUFFERS)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '1095 days', NOW()) FROM user_logs;