SELECT parentregionlist.RegionName, countrylist.CountryName, activepropertylist.Country, 
       activepropertylist.City, activepropertylist.EANHotelID, activepropertylist.Name,
	   activepropertylist.LowRate, activepropertylist.HighRate
FROM activepropertylist
INNER JOIN countrylist
ON activepropertylist.Country = countrylist.CountryCode
INNER JOIN parentregionlist
ON countrylist.ContinentID = parentregionlist.RegionID
ORDER BY Country, City;