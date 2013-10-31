# show all regions than an hotel belongs in Spanish (es_es)
select regionlist_es_es.RegionID,regionlist_es_es.RegionNameLong as RegionName,CenterLatitude,CenterLongitude 
from eanprod.activepropertylist 
JOIN regioneanhotelidmapping
ON activepropertylist.EANHotelID=regioneanhotelidmapping.EANHotelID
JOIN regioncentercoordinateslist
ON regioneanhotelidmapping.RegionID=regioncentercoordinateslist.RegionID
JOIN regionlist_es_es
ON regioneanhotelidmapping.RegionID=regionlist_es_es.RegionID
WHERE activepropertylist.EANHotelID=262633 AND LanguageCode="es_ES";