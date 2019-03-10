SET search-path TO parlgov;

CREATE TABLE q4 (
	year INT,
	countryName VARCHAR(50),
	voteRange VARCHAR(50),
	partyName VARCHAR(50)
);

- match countries and their parties
CREATE VIEW country_party AS
	SELECT c.id AS cid, c.name AS cname, p.id AS pid, p.name AS pname
	FROM country c, party p
	WHERE c.id = p.country_id;

- match elections and results from 1996 to 2016
CREATE VIEW election_result AS
	SELECT e.id AS eid, e.country_id AS cid, EXTRACT(YEAR FROM e.e_date) AS year, e.votes_valid, er.votes
	FROM election e, election_result er
	WHERE e.id = er.election_id AND e.e_date >= ‘1996-01-01’ AND e.e_date <= ‘2016-12-31’ AND e.votes_valid IS NOT NULL AND er.votes IS NOT NULL;

- calculate the ratio of every tuple
CREATE VIEW ratio AS
	SELECT cp.cid AS cid, er.eid AS eid, er.year AS year, er.votes_valid / votes AS ratio
	FROM country_party cp, election_result er
	WHERE cp.cid = er.cid;

- calculate the average ratio of valid votes of party in each year for each country
CREATE VIEW avg_ratio AS
	SELECT cid, eid, year, AVG(ratio) AS ratio
	FROM ratio
	GROUP BY cid, eid, year;

- get name for each country and each party
CREATE VIEW avg_ratio_name AS
SELECT ar.cid, cp.cname, ar.eid, cp.pname, ar.year, ar.ratio
FROM avg_ratio ar, country_party cp
WHERE ar.cid = cp.cid AND ar.pid = cp.pid;

- insert value into result table, one SQL oart for one ratio range
INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT arn.year, arn.cname, ‘(0, 5]’, arn.pname
FROM avg_ratio_name arn
WHERE arn.ratio > 0 AND arn.ratio <= 0.05;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT arn.year, arn.cname, ‘(5, 10]’, arn.pname
FROM avg_ratio_name arn
WHERE arn.ratio > 0.05 AND arn.ratio <= 0.1;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT arn.year, arn.cname, ‘(10, 20]’, arn.pname
FROM avg_ratio_name arn
WHERE arn.ratio > 0.1 AND arn.ratio <= 0.2;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT arn.year, arn.cname, ‘(20, 30]’, arn.pname
FROM avg_ratio_name arn
WHERE arn.ratio > 0.2 AND arn.ratio <= 0.3;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT arn.year, arn.cname, ‘(30, 40]’, arn.pname
FROM avg_ratio_name arn
WHERE arn.ratio > 0.3 AND arn.ratio <= 0.4;

INSERT INTO q4(year, countryName, voteRange, partyName)
SELECT arn.year, arn.cname, ‘(40, 100]’, arn.pname
FROM avg_ratio_name arn
WHERE arn.ratio > 0.4 AND arn.ratio <= 1;
