SET search_path TO parlgov;

SELECT *
FROM q4
ORDER BY year DESC, countryName DESC, voteRange DESC, partyName DESC;
