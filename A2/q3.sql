SET search-path TO parlgov;

CREATE TABLE q3 (
	countryName VARCHAR(50),
	partyName VARCHAR(50),
	partyFamliy VARCHAR(50),
	wonElections INT,
	mostRecentlyWonElectionId INT,
	mostRecentlyWonElectionYear INT
);

- match countries and their parties
CREATE VIEW country_party AS
	SELECT c.id AS cid, c.name AS cname, p.id AS pid, p.name AS pname
	FROM country c, party p
	WHERE c.id = p.country_id;

- find most votes for each election
CREATE VIEW most_votes AS
	SELECT election_id, MAX(votes) AS max_votes
	FROM election_result
	WHERE votes IS NOT NULL
	GROUP BY election_id;

- find winner party for each election
CREATE VIEW winner_party AS
	SELECT er.election_id AS eid, er.party_id AS pid
	FROM election_result er, most_votes mv
	WHERE er.election_id = mv.election_id AND er.max_votes = mv.votes;

- find number of wins for each party and their country
CREATE VIEW num_wins AS
SELECT cp.cid, cp.cname, cp.pid, cp.pname, COUNT(eid) AS num
	FROM winner_party wp, country_party cp
	WHERE wp.pid = cp.pid
	GROUP BY cp.cid, cp.pid;

- find number of average wins for parties in each country
CREATE VIEW avg_wins AS
	SELECT cid, (SUM(num) / COUNT(pid)) AS avg
	FROM num_wins
	GROUP BY cid;

-find parties that have won more than 3 times the average number of winning elections of parties of the same country
CREATE VIEW more_wins AS
	SELECT nw.cid, nw.cname, nw.pid, nw.pname, nw.num
FROM num_wins nw, avg_wins aw
	WHERE nw.cid = aw.cid AND nw.num > (aw.avg * 3);

- get election id and year for all won elections for parties that have won more than 3 times the average number of winning elections of parties of the same country
CREATE VIEW more_wins_with_elec_info AS
SELECT mw.cid, mw.cname, mw.pid, mw.pname, mv.num, wp.eid, EXTRACT(YEAR FROM e.e_date) AS year
	FROM more_wins mw, winner_party wp, election e
	WHERE mw.pid = wp.pid AND wp.eid = e.id;

- get most recently won election id and year for parties that have won more than 3 times the average number of winning elections of parties of the same country
CREATE VIEW most_recent AS
	SELECT cid, cname, pid, pname, num, eid, year
	FROM more_wins_with_elec_info
	WHERE eid NOT IN ( SELECT mwwei1.eid
					 FROM more_wins_with_elec_info mwwei1, more_wins_with_elec_info 					 mwwei2
					 WHERE mwwei1.eid = mwwei2.eid AND mwwei1.year < mwwei2.year);

- get family name for each party and insert into table
INSERT INTO q3(countryName, partyName, partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear)
SELECT mr.cname, mr.pname, pf.family, mr.num, mr.eid, mr.year
FROM most_recent mr, party_family pf
WHERE mr.pid = pf.party_id;
