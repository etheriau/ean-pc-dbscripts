use eanprod;
SELECT activepropertylist.EANHotelID, activepropertylist.Name, count(hotelimagelist.EANHotelID) 
  FROM activepropertylist
LEFT OUTER JOIN hotelimagelist ON activepropertylist.EANHotelID = hotelimagelist.EANHotelID
 GROUP by activepropertylist.EANHotelID
ORDER BY count(hotelimagelist.EANHotelID)
;