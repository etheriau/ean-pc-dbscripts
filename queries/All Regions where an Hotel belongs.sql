# show all regions than an hotel belongs, including Parent Region info.
# but parent Region sometimes is the same data outside USA
# try 4110 - Atlantic City Hotel, 262633 Buenos Aires, AR
# 309567 - Hotel Ares Eiffel (Paris)
use eanprod;
select parentregionlist.RegionID,parentregionlist.RegionName,activepropertylist.EANHotelID,activepropertylist.Name,
parentregionlist.RegionType,parentregionlist.SubClass
FROM activepropertylist
JOIN regioneanhotelidmapping 
ON activepropertylist.EANHotelID=regioneanhotelidmapping.EANHotelID 
JOIN parentregionlist
ON regioneanhotelidmapping.RegionID=parentregionlist.RegionID 
WHERE activepropertylist.EANHotelID IN (309567)
ORDER BY activepropertylist.EANHotelID;