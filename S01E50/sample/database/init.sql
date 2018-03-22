CREATE DATABASE sample;
\c sample;

CREATE TABLE users (
    id integer primary key,
    name text
);
INSERT INTO users (id, name) VALUES (1, 'Chris');
