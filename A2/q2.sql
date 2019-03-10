SET search-path TO parlgov;

CREATE TABLE q2
(	countryName VARCHAR(50),
	partyName VARCHAR(50),
	partyFamliy VARCHAR(50),
	stateMarket FLOAT
);

- match countries and their parties
CREATE VIEW country_party AS
	SELECT c.id AS cid, c.name AS cname, p.id AS pid, p.name AS pname
	FROM country c, party p
	WHERE c.id = p.country_id;

- match countries and their cabinets
CREATE VIEW country_cabinet AS
	SELECT con.id AS country_id, cab.id AS cabinet_id
	FROM country con, cabinet cab
	WHERE con.id = cab.country_id;

- find all committed parties by finding the difference between all possible matches of countries and parties and actual matches between them
CREATE VIEW committed_party AS
	SELECT cid, cname, pid, pname
	FROM country_party
	WHERE pid NOT IN ( SELECT party_id AS pid
					 FROM ( SELECT p.id AS party_id, cc.cabinet_id
							FROM party p, country_cabinet cc
							WHERE p.country_id = cc.country_id
						   	EXCEPT
							SELECT cp.party_id, cp.cabinet_id
							FROM cabinet_party cp, cabinet c
							WHERE cp.cabinet_id = c.id AND c.start_date >= ‘1996-01-01’ 							AND c.start_date <= ‘2016.12.31’)
					 );

- add party family and state marte them insert into the table
INSERT INTO q2(countryName, partyName, partyFamliy, stateMarket)
SELECT cp.cname, cp.pname, pf.family, pp.state_market
FROM committed_party cp, party_family pf, party_position pp
WHERE cp.pid = pf.party_id AND cp.pid = pp.party_id;
