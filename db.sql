CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE likes (
    user_id INTEGER REFERENCES users(id),
    post_id INTEGER REFERENCES posts(id),
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, post_id)
);

CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_likes_post_id ON likes(post_id);

INSERT INTO users (name)
SELECT 'User ' || i
FROM generate_series(1, 50000) AS i;

INSERT INTO posts (user_id, content, created_at)
SELECT 
    (random() * 49999 + 1)::INT,
    'Content for post ' || i,
    NOW() - (random() * interval '365 days')
FROM generate_series(1, 500000) AS i;

INSERT INTO likes (user_id, post_id)
SELECT 
    (random() * 49999 + 1)::INT,
    (random() * 499999 + 1)::INT
FROM generate_series(1, 2000000) AS i
ON CONFLICT DO NOTHING;