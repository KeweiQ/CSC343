SET search_path TO parlgov;
DROP TABLE IF EXISTS q3 cascade;

CREATE TABLE q3(
	countryName VARCHAR(50),
	partyName VARCHAR(50),
	partyFamily VARCHAR(50),
	wonElections INT,
	mostRecentlyWonElectionId INT,
	mostRecentlyWonElectionYear INT
);

DROP VIEW IF EXISTS country_party CASCADE;
DROP VIEW IF EXISTS most_votes CASCADE;
DROP VIEW IF EXISTS winner_party CASCADE;
DROP VIEW IF EXISTS num_wins CASCADE;
DROP VIEW IF EXISTS avg_wins CASCADE;
DROP VIEW IF EXISTS more_wins CASCADE;
DROP VIEW IF EXISTS more_wins_with_elec_info CASCADE;
DROP VIEW IF EXISTS most_recent CASCADE;

-- match countries and their parties
CREATE VIEW country_party AS
	SELECT c.id AS cid, c.name AS cname, p.id AS pid, p.name AS pname
	FROM country c, party p
	WHERE c.id = p.country_id;

-- find most votes for each election
CREATE VIEW most_votes AS
	SELECT election_id, MAX(votes) AS max_votes
	FROM election_result
	WHERE votes IS NOT NULL
	GROUP BY election_id;

-- find winner party for each election
CREATE VIEW winner_party AS
	SELECT er.election_id AS eid, er.party_id AS pid
	FROM election_result er, most_votes mv
	WHERE er.election_id = mv.election_id AND er.votes IS NOT NULL AND er.votes = mv.max_votes;

-- find number of wins for each party and their country
CREATE VIEW num_wins AS
	SELECT cp.cid, cp.cname, cp.pid, cp.pname, COUNT(eid) AS party_win_num
	FROM winner_party wp, country_party cp
	WHERE wp.pid = cp.pid
	GROUP BY cp.cid, cp.cname, cp.pid, cp.pname;

-- count number of parties for each country
CREATE VIEW denominator AS
	SELECT cid, COUNT(pid) AS party_num
	FROM country_party
	GROUP BY cid;

-- count number of total wins of all parties for each country
CREATE VIEW numerator AS
	SELECT cid, SUM(party_win_num) AS country_win_num
	FROM num_wins
	GROUP BY cid;

-- find number of average wins for parties in each country
CREATE VIEW avg_wins AS
	SELECT d.cid, (n.country_win_num::float / d.party_num::float) AS avg_wins
	FROM denominator d, numerator n
	WHERE d.cid = n.cid;

--find parties that have won more than 3 times the average number of winning elections of parties of the same country
CREATE VIEW more_wins AS
	SELECT nw.cid, nw.cname, nw.pid, nw.pname, nw.party_win_num AS num
	FROM num_wins nw, avg_wins aw
	WHERE nw.cid = aw.cid AND nw.party_win_num > (aw.avg_wins * 3);

-- get election id and year for all won elections for parties that have won more than 3 times the average number of winning elections of parties of the same country
CREATE VIEW more_wins_with_elec_info AS
	SELECT mw.cid, mw.cname, mw.pid, mw.pname, mw.num, wp.eid, EXTRACT(YEAR FROM e.e_date) AS year
	FROM more_wins mw, winner_party wp, election e
	WHERE mw.pid = wp.pid AND wp.eid = e.id;

-- get most recently won election id and year for parties that have won more than 3 times the average number of winning elections of parties of the same country
CREATE VIEW most_recent AS
	SELECT cid, cname, pid, pname, num, eid, year
	FROM more_wins_with_elec_info
	WHERE eid NOT IN ( SELECT mwwei1.eid
			   FROM more_wins_with_elec_info mwwei1, more_wins_with_elec_info mwwei2
			   WHERE mwwei1.eid = mwwei2.eid AND mwwei1.year < mwwei2.year);

-- get family name for each party and insert into table
INSERT INTO q3(countryName, partyName, partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear)
SELECT mr.cname, mr.pname, pf.family, mr.num, mr.eid, mr.year
FROM most_recent mr, party_family pf
WHERE mr.pid = pf.party_id;
