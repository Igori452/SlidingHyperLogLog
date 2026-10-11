\timing on

-- Запросы для датасета в 200 млн за 3 года

-- 0.5 год
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(DISTINCT user_id) AS unique_users_180d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '180 days';
SELECT COUNT(DISTINCT user_id) AS unique_users_180d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '180 days';

-- 1 год
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(DISTINCT user_id) AS unique_users_365d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '365 days';
SELECT COUNT(DISTINCT user_id) AS unique_users_365d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '365 days';

-- 2 года
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(DISTINCT user_id) AS unique_users_730d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '730 days';
SELECT COUNT(DISTINCT user_id) AS unique_users_730d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '730 days';

-- 2 года, закончившихся 1 год назад
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(DISTINCT user_id) AS unique_users_730d_ending_1y_ago
FROM user_logs
WHERE viewed_at >= NOW() - INTERVAL '1095 days'
  AND viewed_at <  NOW() - INTERVAL '365 days';
SELECT COUNT(DISTINCT user_id) AS unique_users_730d_ending_1y_ago
FROM user_logs
WHERE viewed_at >= NOW() - INTERVAL '1095 days'
  AND viewed_at <  NOW() - INTERVAL '365 days';

SELECT COUNT(*), MIN(viewed_at), MAX(viewed_at) FROM user_logs;