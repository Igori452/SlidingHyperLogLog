\timing on

SELECT sliding_count_distinct(user_id, INTERVAL '2 hours') AS unique_users_2h
FROM user_logs;

SELECT sliding_count_distinct(user_id, INTERVAL '6 hours') AS unique_users_6h
FROM user_logs;