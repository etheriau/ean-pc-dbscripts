use eanextras;
select airports.AirportCode,AirportType,AirportName,IATACode,airports.ISOCountry,
       ISORegion,regions.RegionCode,Municipality,
       regions.RegionLocalCode,regions.ISOCountry
	   ,eanprod.activepropertylist.EANHotelID,
	   eanprod.activepropertylist.Name
 FROM eanprod.activepropertylist
INNER JOIN eanextras.airports
	ON INSTR(activepropertylist.City, Municipality) > 0
#   ON  activepropertylist.City = airports.Municipality
INNER JOIN eanextras.regions
   ON airports.ISORegion = regions.RegionCode
WHERE eanextras.airports.AirportType="large_airport"
   AND IATACode <> ""
##   AND RegionLocalCode = "TX"
;