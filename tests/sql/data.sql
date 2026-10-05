CREATE EXTENSION IF NOT EXISTS sliding_hll;

DROP TABLE IF EXISTS user_logs;

CREATE TABLE user_logs (
    id SERIAL PRIMARY KEY,
    user_id INT,
    viewed_at TIMESTAMP DEFAULT NOW()
);

-- Заполняем данными с разным временем
INSERT INTO user_logs (user_id, viewed_at) VALUES 
(1, NOW()), 
(2, NOW() - INTERVAL '10 minutes'),
(2, NOW() - INTERVAL '30 minutes');

-- Около 1.5 - 2 часов назад
INSERT INTO user_logs (user_id, viewed_at) VALUES 
(1, NOW() - INTERVAL '90 minutes'),
(3, NOW() - INTERVAL '110 minutes');

-- Более 3 часов назад
INSERT INTO user_logs (user_id, viewed_at) VALUES 
(3, NOW() - INTERVAL '4 hours'),
(4, NOW() - INTERVAL '5 hours');