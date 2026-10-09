\timing on

-- Запросы для датасета в 500 млн за 5 лет

-- 1 год
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '365 days', NOW()) AS unique_users_365d FROM user_logs;
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '365 days', NOW()) AS unique_users_365d FROM user_logs;


-- 2 года
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '730 days', NOW()) AS unique_users_730d FROM user_logs;
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '730 days', NOW()) AS unique_users_730d FROM user_logs;


-- 4 года
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '1460 days', NOW()) AS unique_users_1460d FROM user_logs;
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '1460 days', NOW()) AS unique_users_1460d FROM user_logs;


-- 2 года, закончившихся 1 год назад
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '730 days',
       NOW() - INTERVAL '365 days') AS unique_users_730d_ending_1y_ago
FROM user_logs;
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '730 days',
       NOW() - INTERVAL '365 days') AS unique_users_730d_ending_1y_ago
FROM user_logs;


-- первый год (самый старый год датасета)
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '365 days',
       NOW() - INTERVAL '1460 days') AS unique_users_first_year
FROM user_logs;
SELECT sliding_count_distinct(viewed_at::timestamptz, user_id::bigint,
       INTERVAL '365 days',
       NOW() - INTERVAL '1460 days') AS unique_users_first_year
FROM user_logs;