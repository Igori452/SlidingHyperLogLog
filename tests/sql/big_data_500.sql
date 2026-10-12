DROP EXTENSION IF EXISTS sliding_hll;
CREATE EXTENSION IF NOT EXISTS sliding_hll;

DROP TABLE IF EXISTS user_logs;

CREATE TABLE user_logs (
    id SERIAL PRIMARY KEY,
    user_id INT,
    viewed_at TIMESTAMP DEFAULT NOW()
);

COPY user_logs(user_id, viewed_at) FROM '/tmp/data_500.csv' WITH (FORMAT csv);

CREATE INDEX user_logs_viewed_at_idx ON user_logs(viewed_at);
ANALYZE user_logs;

SELECT pg_size_pretty(pg_relation_size('user_logs'));
SELECT pg_size_pretty(pg_relation_size('user_logs_viewed_at_idx'));