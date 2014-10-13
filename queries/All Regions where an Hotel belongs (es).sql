# show all regions than an hotel belongs in Spanish (es_es)
select regionlist_es_es.RegionID,regionlist_es_es.RegionNameLong as 'RegionNameFull', parentregionlist.RegionName 
from eanprod.activepropertylist 
JOIN regioneanhotelidmapping
ON activepropertylist.EANHotelID=regioneanhotelidmapping.EANHotelID
JOIN parentregionlist
ON regioneanhotelidmapping.RegionID=parentregionlist.RegionID
JOIN regionlist_es_es
ON regioneanhotelidmapping.RegionID=regionlist_es_es.RegionID
WHERE activepropertylist.EANHotelID=163375 AND LanguageCode="es_ES";