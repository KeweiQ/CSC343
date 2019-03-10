SET search-path TO parlgov;

CREATE TEBLE q6 (
	countryName VARCHAR(50),
	r0_2 INT,
	r2_4 INT,
	r4_6 INT,
	r6_8 INT,
	r8_10 INT
);

- match country and their parties, persist countries which have no parties
CREATE VIEW country_patry AS
	SELECT c.id AS cid, c.name AS cname, p.id AS pid
	FROM country c LEFT JOIN party p
	ON c.id = p.country_id;

- match parties in each country with their positions
CREATE VIEW country_party_position AS
	SELECT cp.cid, cp.pid cp.cname, pp.left_right
	FROM country_party cp LEFT JOIN party_position pp
	ON cp.pid = pp.party_id;

- count the number of parties which have their position in range 0 to 2 for each country
CREATE VIEW range02 AS
	SELECT cname AS countryName, count(left_right) AS r0-2
	FROM country_party_position
	WHERE left_right >= 0 AND left_right < 2
	GROUP BY cname;

- count the number of parties which have their position in range 2 to 4 for each country
CREATE VIEW range24 AS
	SELECT cname AS countryName, count(left_right) AS r2-4
	FROM country_party_position
	WHERE left_right >= 2 AND left_right < 4
	GROUP BY cname;

- count the number of parties which have their position in range 4 to 6 for each country
CREATE VIEW range46 AS
	SELECT cname AS countryName, count(left_right) AS r4-6
	FROM country_party_position
	WHERE left_right >= 4 AND left_right < 6
	GROUP BY cname;

- count the number of parties which have their position in range 6 to 8 for each country
CREATE VIEW range68 AS
	SELECT cname AS countryName, count(left_right) AS r6-8
	FROM country_party_position
	WHERE left_right >= 6 AND left_right < 8
	GROUP BY cname;

- count the number of parties which have their position in range 8 to 10 for each country
CREATE VIEW range810 AS
	SELECT cname AS countryName, count(left_right) AS r8-10
	FROM country_party_position
	WHERE left_right >= 8 AND left_right < 10
	GROUP BY cname;

INSERT INTO q6 (countryName, r0_2, r2_4, r4_6, r6_8, r8_10)
SELECT
FROM country_party_position, range02, range24, range46, range68, range810
WHERE country_party_position.cid = range02.cid AND range02.cid = range24.cid AND range24.cid = range46.cid AND range46.cid = range68.cid AND range68.cid = range810.cid;
