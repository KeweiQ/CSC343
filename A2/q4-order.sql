SET search-path TO parlgov;

SELECT *
FROM q4
GROUP BY year DESC, countryName DESC, voteRange DESC, partyName, DESC;
