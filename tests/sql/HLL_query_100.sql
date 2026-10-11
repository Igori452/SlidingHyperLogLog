\timing on

-- Запросы для датасета в 200 млн за 3 года

-- 30 дней
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '30 days', NOW()) AS unique_users_30d FROM user_logs;
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '30 days', NOW()) AS unique_users_30d FROM user_logs;

-- 0.3 года
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '90 days', NOW()) AS unique_users_90d FROM user_logs;
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '90 days', NOW()) AS unique_users_90d FROM user_logs;

-- 0.7 года
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '200 days', NOW()) AS unique_users_200d FROM user_logs;
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '200 days', NOW()) AS unique_users_200d FROM user_logs;

-- последние пол года
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '190 days',
       NOW() - INTERVAL '180 days') AS unique_users_180d_ending_180d_ago
FROM user_logs;
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '190 days',
       NOW() - INTERVAL '180 days') AS unique_users_180d_ending_180d_ago
FROM user_logs;