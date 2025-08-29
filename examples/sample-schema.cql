-- Sample Cassandra Schema
-- This file contains example keyspace and table definitions

-- Create a keyspace for the demo application
CREATE KEYSPACE IF NOT EXISTS demo_keyspace 
WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
};

-- Use the demo keyspace
USE demo_keyspace;

-- Create a users table
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY,
    username text,
    email text,
    first_name text,
    last_name text,
    created_at timestamp,
    is_active boolean
);

-- Create a posts table
CREATE TABLE IF NOT EXISTS posts (
    post_id UUID PRIMARY KEY,
    user_id UUID,
    title text,
    content text,
    created_at timestamp,
    updated_at timestamp,
    tags set<text>
);

-- Create a comments table
CREATE TABLE IF NOT EXISTS comments (
    comment_id UUID PRIMARY KEY,
    post_id UUID,
    user_id UUID,
    content text,
    created_at timestamp,
    parent_comment_id UUID
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS ON users (username);
CREATE INDEX IF NOT EXISTS ON users (email);
CREATE INDEX IF NOT EXISTS ON posts (user_id);
CREATE INDEX IF NOT EXISTS ON comments (post_id);

-- Insert sample data
INSERT INTO users (user_id, username, email, first_name, last_name, created_at, is_active) 
VALUES (uuid(), 'john_doe', 'john@example.com', 'John', 'Doe', toTimestamp(now()), true);

INSERT INTO users (user_id, username, email, first_name, last_name, created_at, is_active) 
VALUES (uuid(), 'jane_smith', 'jane@example.com', 'Jane', 'Smith', toTimestamp(now()), true);

-- Insert sample posts
INSERT INTO posts (post_id, user_id, title, content, created_at, updated_at, tags) 
VALUES (uuid(), (SELECT user_id FROM users WHERE username = 'john_doe' LIMIT 1), 
        'My First Post', 'This is my first post content', toTimestamp(now()), toTimestamp(now()), {'demo', 'first'});

-- Insert sample comments
INSERT INTO comments (comment_id, post_id, user_id, content, created_at) 
VALUES (uuid(), (SELECT post_id FROM posts WHERE title = 'My First Post' LIMIT 1),
        (SELECT user_id FROM users WHERE username = 'jane_smith' LIMIT 1),
        'Great first post!', toTimestamp(now()));

-- Query examples
-- Get all users
SELECT * FROM users;

-- Get posts by user
SELECT * FROM posts WHERE user_id = (SELECT user_id FROM users WHERE username = 'john_doe' LIMIT 1);

-- Get comments for a post
SELECT * FROM comments WHERE post_id = (SELECT post_id FROM posts WHERE title = 'My First Post' LIMIT 1);

-- Count total users
SELECT COUNT(*) FROM users;

-- Get users created today
SELECT * FROM users WHERE created_at >= toTimestamp(now()) - 1d;
