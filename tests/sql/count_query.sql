\timing on

SELECT COUNT(DISTINCT user_id) AS unique_users_2h
FROM user_logs
WHERE viewed_at >= NOW() - INTERVAL '2 hours';

SELECT COUNT(DISTINCT user_id) AS unique_users_6h
FROM user_logs
WHERE viewed_at >= NOW() - INTERVAL '6 hours';