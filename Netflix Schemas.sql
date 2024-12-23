-- SCHEMAS of Netflix

DROP table if exists netflix;

CREATE TABLE netflix (
    show_id VARCHAR(7),
    show_type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(210),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(150),
    descriptions VARCHAR(250)
);

SELECT * FROM netflix;
