SELECT parentregionlist.RegionName, countrylist.CountryName, activepropertylist.Country, activepropertylist.City, Count(*) AS HotelsInCity
FROM activepropertylist
INNER JOIN countrylist
ON activepropertylist.Country = countrylist.CountryCode
INNER JOIN parentregionlist
ON countrylist.ContinentID = parentregionlist.RegionID
GROUP BY Country, City;