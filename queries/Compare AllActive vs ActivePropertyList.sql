use eanextras;
SELECT expediaactive.HotelID,expediaactive.Name as HotelName,
	activepropertylist.EANHotelID,
        activepropertylist.Name
 from eanextras.expediaactive
LEFT JOIN eanprod.activepropertylist
ON expediaactive.HotelID=activepropertylist.EANHotelID
WHERE expediaactive.Name<>activepropertylist.Name
ORDER BY HotelID;