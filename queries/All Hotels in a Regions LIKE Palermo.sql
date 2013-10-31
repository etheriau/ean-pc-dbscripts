select RegionName,activepropertylist.EANHotelID,Name 
from regioncentercoordinateslist 
JOIN regioneanhotelidmapping
ON regioncentercoordinateslist.RegionID=regioneanhotelidmapping.RegionID
JOIN activepropertylist
ON regioneanhotelidmapping.EANHotelID=activepropertylist.EANHotelID
WHERE Country="AR" and RegionName LIKE "%Palermo%" ORDER BY regioncentercoordinateslist.RegionID;
