# show all hotels in a given RegionID
# 6148556 - Champs-Elysees, Paris, France
select regioncentercoordinateslist.RegionID,regioncentercoordinateslist.RegionName,
activepropertylist.EANHotelID,activepropertylist.Name,Address1,Address2,City,StateProvince,PostalCode 
FROM activepropertylist
JOIN regioneanhotelidmapping 
ON activepropertylist.EANHotelID=regioneanhotelidmapping.EANHotelID 
JOIN regioncentercoordinateslist 
ON regioneanhotelidmapping.RegionID=regioncentercoordinateslist.RegionID 
WHERE regioncentercoordinateslist.RegionID = 6148556
ORDER BY activepropertylist.EANHotelID;