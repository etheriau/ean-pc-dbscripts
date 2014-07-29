use eanprod;
select parentregionlist.RegionID, parentregionlist.RegionNameLong,Count(*) AS HotelsInRegion
FROM parentregionlist
JOIN regioneanhotelidmapping
ON parentregionlist.RegionID = regioneanhotelidmapping.RegionID
WHERE parentregionlist.RegionID IN (3132,178305,800129,6151902)
GROUP BY parentregionlist.RegionID;
