\timing on

-- Запросы для датасета в 100 млн за 1 год

-- 30 дней
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(DISTINCT user_id) AS unique_users_30d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '30 days';
SELECT COUNT(DISTINCT user_id) AS unique_users_30d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '30 days';

-- 0.3 года
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(DISTINCT user_id) AS unique_users_90d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '90 days';
SELECT COUNT(DISTINCT user_id) AS unique_users_90d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '90 days';

-- 0.7 года
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(DISTINCT user_id) AS unique_users_200d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '200 days';
SELECT COUNT(DISTINCT user_id) AS unique_users_200d
FROM user_logs WHERE viewed_at >= NOW() - INTERVAL '200 days';

-- первые пол года
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(DISTINCT user_id) AS unique_users_180d_ending_180d_ago
FROM user_logs
WHERE viewed_at >= NOW() - INTERVAL '370 days'
  AND viewed_at <  NOW() - INTERVAL '180 days';
SELECT COUNT(DISTINCT user_id) AS unique_users_180d_ending_180d_ago
FROM user_logs
WHERE viewed_at >= NOW() - INTERVAL '370 days'
  AND viewed_at <  NOW() - INTERVAL '180 days';

SELECT COUNT(*), MIN(viewed_at), MAX(viewed_at) FROM user_logs;