CREATE EXTENSION IF NOT EXISTS sliding_hll;

DROP TABLE IF EXISTS user_logs;

CREATE TABLE user_logs (
    id SERIAL PRIMARY KEY,
    user_id INT,
    viewed_at TIMESTAMP DEFAULT NOW()
);

COPY user_logs(user_id, viewed_at) FROM '/tmp/data.csv' WITH (FORMAT csv);

CREATE INDEX ON user_logs(viewed_at);
ANALYZE user_logs;