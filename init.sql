CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR NOT NULL);
CREATE TABLE posts (id SERIAL PRIMARY KEY, user_id INTEGER, content TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE likes (user_id INTEGER, post_id INTEGER, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (user_id, post_id));

CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_likes_post_id ON likes(post_id);

INSERT INTO users (name) SELECT 'User ' || i FROM range(1, 50001) t(i);
INSERT INTO posts (user_id, content, created_at) SELECT CAST(random() * 49999 + 1 AS INT), 'Content for post ' || i, CURRENT_TIMESTAMP - CAST(random() * 365 AS INTEGER) * INTERVAL '1 DAY' FROM range(1, 500001) t(i);
INSERT OR IGNORE INTO likes (user_id, post_id) SELECT CAST(random() * 49999 + 1 AS INT), CAST(random() * 499999 + 1 AS INT) FROM range(1, 2000001) t(i);