# All POIs in Spanish
select regionlist_es_es.RegionID,regionlist_es_es.RegionName,regionlist_es_es.RegionNameLong,RegionType,SubClass
FROM regionlist_es_es
# get the parent where that POI is located
JOIN parentregionlist
ON regionlist_es_es.RegionID = parentregionlist.RegionID
where RegionType="Point of Interest";