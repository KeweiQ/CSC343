SET search_path TO parlgov;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5(
	countryName VARCHAR(50),
	year INT,
	participationRatio FLOAT
);

DROP VIEW IF EXISTS country_election CASCADE;
DROP VIEW IF EXISTS avg_each_year CASCADE;
DROP VIEW IF EXISTS country_has_increase CASCADE;
DROP VIEW IF EXISTS country_non_decrease CASCADE;

-- match countries and elections
-- pick out elections from 2001 to 2016
CREATE VIEW country_election AS
	SELECT country_id AS cid, id AS eid, EXTRACT(YEAR FROM e_date) AS year, (votes_cast::float / electorate::float) AS ratio
	FROM election
	WHERE e_date >= '2001-01-01' AND e_date <= '2016-12-31' AND votes_cast IS NOT NULL AND electorate IS NOT NULL;

-- calculate the average ratio of election in each year for each country
CREATE VIEW avg_each_year AS
	SELECT cid, year, AVG(ratio) AS ratio
	FROM country_election
	GROUP BY cid, year;

-- find all countries which has come year's election ratio less than some previous year's ratio
CREATE VIEW country_has_decrease AS
	SELECT DISTINCT a1.cid AS cid
	FROM avg_each_year a1, avg_each_year a2
	WHERE a1.cid = a2.cid AND a1.year < a2.year AND a1.ratio > a2.ratio;

-- find all countries whose average election participation ratios during this period are monotonically non-decreasing
CREATE VIEW country_non_decrease AS
	SELECT cid, year, ratio
	FROM avg_each_year
	WHERE cid NOT IN ( SELECT cid
			   FROM country_has_decrease);

INSERT INTO q5(countryName, year, participationRatio)
SELECT c.name, cnd.year, cnd.ratio
FROM country c, country_non_decrease cnd
WHERE c.id = cnd.cid;
