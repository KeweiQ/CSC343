SET search_path TO parlgov;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
	countryId INT,
	alliedPartyId1 INT,
	alliedPartyId2 INT
);

DROP VIEW IF EXISTS alliance CASCADE;
DROP VIEW IF EXISTS alliance_with_country CASCADE;
DROP VIEW IF EXISTS country_election CASCADE;

-- find pairs of parties in alliances
CREATE VIEW alliance AS
	SELECT er1.election_id AS eid, er1.party_id AS pid1, er2.party_id AS pid2
	FROM election_result er1, election_result er2
	WHERE er1.election_id = er2.election_id AND er1.party_id < er2.party_id AND (er1.id = er2.alliance_id OR er1.alliance_id = er2.id OR er1.alliance_id = er2.alliance_id);

-- add country information
CREATE VIEW alliance_with_country AS
	SELECT e.country_id AS cid, a.eid, a.pid1, a.pid2
	FROM alliance a, election e
	WHERE a.eid = e.id;

-- match count number of elections in each country
CREATE VIEW country_election AS
	SELECT country_id AS cid, COUNT(id) as elec_num
	FROM election
GROUP BY country_id;

INSERT INTO q1(countryId, alliedPartyId1, alliedPartyId2)
SELECT awc.cid, awc.pid1, awc.pid2
FROM alliance_with_country awc, country_election ce
WHERE awc.cid = ce.cid
GROUP BY awc.cid, awc.pid1, awc.pid2, ce.elec_num
HAVING COUNT(awc.eid) >= (ce.elec_num::float * 0.3);
