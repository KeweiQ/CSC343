SET search-path TO parlgov;

CREATE TABLE q5 (
	countryName VARCHAR(50),
	year INT,
	participationRatio FLOAT
);

- match countries and elections
- pick out elections from 2001 to 2016
CREATE VIEW country_election AS
	SELECT c.id AS cid, e.id AS eid, EXTRACT(YEAR FROM e.e_date) AS year, e.votes_cast / e.electorate AS ratio
	FROM country c, election e
WHERE c.id = e.country_id AND e.e_date >= ‘2001-01-01’ AND e.e_date <= ‘2016-12-31’ AND e.votes_cast IS NOT NULL AND e.electorate IS NOT NULL;

- calculate the average ratio of election in each year for each country
CREATE VIEW avg_each_year AS
	SELECT cid, year, AVG(ratio) AS ratio
	FROM country_election
	GROUP BY cid, year;

- find all countries which has come year’s election ratio less than some previous year’s ratio
CREATE VIEW country_has_increase AS
	SELECT a1.cid AS cid
	FROM avg_each_year a1, avg_each_year a2
	WHERE a1.cname = a2.cname AND a1.year < a2.year AND a1.ratio > a2.ratio;

- find all countries whose average election participation ratios during this period are monotonically non-decreasing
CREATE VIEW country_non_decrease AS
	SELECT cid, year, ratio AS participationRatio
	FROM avg_each_year
	WHERE cid NOT IN ( SELECT cid
						FROM country_non_decrease);

INSERT INTO q5(countryName, year, participationRatio)
SELECT c.name, cnd.year, cnd.ratio
FROM country c, country_non_decrease cnd
WHERE c.id = cnd.cid;
