DROP EXTENSION IF EXISTS sliding_hll;
CREATE EXTENSION IF NOT EXISTS sliding_hll;

DROP TABLE IF EXISTS user_logs;

CREATE TABLE user_logs (
    id SERIAL PRIMARY KEY,
    user_id INT,
    viewed_at TIMESTAMP DEFAULT NOW()
);

COPY user_logs(user_id, viewed_at) FROM '/tmp/data_200.csv' WITH (FORMAT csv);

CREATE INDEX ON user_logs(viewed_at);
ANALYZE user_logs;

SELECT pg_size_pretty(pg_relation_size('user_logs'));