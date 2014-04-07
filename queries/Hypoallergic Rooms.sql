use eanprod;
select roomtypelist.EANHotelID,activepropertylist.Name,roomtypelist.RoomTypeID,roomtypelist.RoomTypeName,roomtypelist.RoomTypeDescription from roomtypelist
JOIN activepropertylist
ON  roomtypelist.EANHotelID= activepropertylist.EANHotelID
where RoomTypeDescription like "%hypoallergenic%";