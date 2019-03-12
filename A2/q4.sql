SET search_path TO parlgov;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4(
	year INT,
	countryName VARCHAR(100),
	voteRange VARCHAR(100),
	partyName VARCHAR(100)
);

DROP VIEW IF EXISTS country_party CASCADE;
DROP VIEW IF EXISTS elec_result CASCADE;
DROP VIEW IF EXISTS ratio CASCADE;
DROP VIEW IF EXISTS avg_ratio CASCADE;
DROP VIEW IF EXISTS avg_ratio_name CASCADE;

-- match countries and their parties
CREATE VIEW country_party AS
	SELECT c.id AS cid, c.name AS cname, p.id AS pid, p.name AS pname
	FROM country c, party p
	WHERE c.id = p.country_id;

-- match elections and results from 1996 to 2016
CREATE VIEW elec_result AS
	SELECT e.country_id AS cid, er.party_id AS pid, EXTRACT(YEAR FROM e.e_date) AS year, e.votes_valid, er.votes
	FROM election e, election_result er
	WHERE e.id = er.election_id AND e.e_date >= '1996-01-01' AND e.e_date <= '2016-12-31' AND e.votes_valid IS NOT NULL AND er.votes IS NOT NULL;

-- calculate the ratio of every tuple
CREATE VIEW ratio AS
	SELECT cp.cid, cp.cname, cp.pid, cp.pname, er.year, (votes::float / er.votes_valid::float) AS ratio
	FROM country_party cp, elec_result er
	WHERE cp.cid = er.cid AND cp.pid = er.pid;

-- calculate the average ratio of valid votes of party in each year for each country
CREATE VIEW avg_ratio AS
	SELECT cid, cname, pid, pname, year, AVG(ratio) AS ratio
	FROM ratio
	GROUP BY cid, cname, pid, pname, year;

-- insert value into result table, one SQL oart for one ratio range
INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT ar.year, ar.cname, '(0, 5]', ar.pname
FROM avg_ratio ar
WHERE ar.ratio > 0 AND ar.ratio <= 0.05;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT ar.year, ar.cname, '(5, 10]', ar.pname
FROM avg_ratio ar
WHERE ar.ratio > 0.05 AND ar.ratio <= 0.1;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT ar.year, ar.cname, '(10, 20]', ar.pname
FROM avg_ratio ar
WHERE ar.ratio > 0.1 AND ar.ratio <= 0.2;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT ar.year, ar.cname, '(20, 30]', ar.pname
FROM avg_ratio ar
WHERE ar.ratio > 0.2 AND ar.ratio <= 0.3;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT ar.year, ar.cname, '(30, 40]', ar.pname
FROM avg_ratio ar
WHERE ar.ratio > 0.3 AND ar.ratio <= 0.4;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT ar.year, ar.cname, '(40, 100]', ar.pname
FROM avg_ratio ar
WHERE ar.ratio > 0.4 AND ar.ratio <= 1;
