# show all regions than an hotel belongs, including Parent Region info.
# but parent Region sometimes is the same data outside USA
# try 4110 - Atlantic City Hotel, 262633 Buenos Aires, AR
use eanprod;
select regioncentercoordinateslist.RegionID,regioncentercoordinateslist.RegionName,
parentregionlist.RegionName as ParentRegionName,
parentregionlist.RegionNameLong as ParentRegionNameLong,
parentregionlist.RegionName as ParentRegionType,
parentregionlist.RelativeSignificance,
parentregionlist.SubClass,
CenterLatitude,CenterLongitude 
FROM activepropertylist
JOIN regioneanhotelidmapping 
ON activepropertylist.EANHotelID=regioneanhotelidmapping.EANHotelID 
JOIN regioncentercoordinateslist 
ON regioneanhotelidmapping.RegionID=regioncentercoordinateslist.RegionID 
JOIN parentregionlist 
ON regioncentercoordinateslist.RegionID=parentregionlist.RegionID 
WHERE activepropertylist.EANHotelID IN (4110,262633,309567)
ORDER BY activepropertylist.EANHotelID;