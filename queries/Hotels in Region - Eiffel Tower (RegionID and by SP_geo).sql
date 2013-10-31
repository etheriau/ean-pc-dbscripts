## Find all hotels in the Region that defines the 
## Eiffel Tower (RegionID - 800093)
## you can also use the GeoPoint + Stored Procedure instead
SELECT regioncentercoordinateslist.RegionID,RegionName,activepropertylist.EANHotelID,Name 
FROM regioncentercoordinateslist 
INNER JOIN regioneanhotelidmapping
ON regioncentercoordinateslist.RegionID=regioneanhotelidmapping.RegionID
INNER JOIN activepropertylist
ON regioneanhotelidmapping.EANHotelID=activepropertylist.EANHotelID
WHERE RegionName LIKE "%Eiffel%";
## Using the GPSPoint(48.854636,2.310101) taken out
## of the RegionCenterCoordinatesList
#call sp_hotels_from_point(48.854636,2.310101,1);