SET search-path TO parlgov;

SELECT *
FROM q2
ORDER BY countryName, partyName, stateMarket DESC;
