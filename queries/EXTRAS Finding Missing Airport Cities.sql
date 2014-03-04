USE eanprod;
SELECT airportcoordinateslist.AirportCode,airportcoordinateslist.AirportName,airports.IATACode,airports.AirportName,
ISOCountry,ISORegion,Municipality 
FROM eanprod.airportcoordinateslist
JOIN eanextras.airports 
ON eanprod.airportcoordinateslist.AirportCode=eanextras.airports.IATACode 
WHERE airportcoordinateslist.MainCityID <> 0;