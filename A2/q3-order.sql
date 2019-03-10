SET search-path TO parlgov;

SELECT *
FROM q3
ORDER BY countryName, wonElections, partyName DESC;
