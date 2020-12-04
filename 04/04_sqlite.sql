DROP TABLE IF EXISTS passports;


-- From SQLite extensions. Download regexp.c and compile
-- https://www.sqlite.org/src/file?name=ext/misc/regexp.c

.load regexp.dylib

CREATE TABLE passports(
  birth_year TEXT, issue_year INT, expiry_year INT, height INT,
  hair_colour TEXT, eye_colour TEXT, passport_id TEXT, country_id INT,

  -- Generated columns to pull out unit and value from height
  height_unit TEXT GENERATED ALWAYS AS (substr(height, -2)) STORED,
  height_value INT GENERATED ALWAYS AS (substr(height, 0, length(height)-1)) STORED
);

INSERT INTO passports SELECT
  json_extract(value, '$.byr'),
  json_extract(value, '$.iyr'),
  json_extract(value, '$.eyr'),
  json_extract(value, '$.hgt'),
  json_extract(value, '$.hcl'),
  json_extract(value, '$.ecl'),
  json_extract(value, '$.pid'),
  json_extract(value, '$.cid')
FROM json_each(readfile('04_input.json'));

-- Part 1

select count(*) from passports where "" not in (
  birth_year, issue_year, expiry_year, height, hair_colour, eye_colour, passport_id
);

-- Part 2

select count(*) from passports where
  birth_year between 1920 and 2002 AND
  issue_year between 2010 and 2020 AND
  expiry_year between 2020 and 2030 AND
  (
    height_unit = 'cm' AND height_value between 150 and 193
      OR
    height_unit = 'in' AND height_value between 59 and 76
  ) AND
  hair_colour regexp "#[0-9a-f]{6}" AND
  eye_colour in ("amb","blu","brn","gry","grn","hzl","oth") AND
  length(passport_id) = 9 order by 1 desc;
