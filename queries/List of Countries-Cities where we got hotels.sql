SELECT DISTINCT activepropertylist.Country, countrylist.CountryName, activepropertylist.City
FROM activepropertylist 
INNER JOIN countrylist
ON activepropertylist.Country = countrylist.CountryCode 
ORDER BY Country, City;