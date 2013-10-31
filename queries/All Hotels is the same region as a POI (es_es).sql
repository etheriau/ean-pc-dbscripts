#get hotels near a POI in Spanish language
select regionlist_es_es.RegionID,regionlist_es_es.RegionName,regionlist_es_es.RegionNameLong,RegionType,SubClass,ParentRegionID,ParentRegionType, 
       ParentRegionName, ParentRegionNameLong,activepropertylist.EANHotelID, Name 
FROM regionlist_es_es
# get the parent where that POI is located
JOIN parentregionlist
ON regionlist_es_es.RegionID = parentregionlist.RegionID
# now link to the regions to hotels mapping to get a list of eanhotelids
JOIN regioneanhotelidmapping
ON parentregionlist.ParentRegionID = regioneanhotelidmapping.RegionID
# now get those hotel name, you do not need this step to fill the eanhotelid list
JOIN activepropertylist
ON regioneanhotelidmapping.EANHotelID = activepropertylist.EANHotelID
where regionlist_es_es.RegionName LIKE "%Bernabeu%" and RegionType="Point of Interest";
