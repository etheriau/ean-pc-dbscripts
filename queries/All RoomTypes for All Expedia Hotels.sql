# Presenting all RoomTypes for all Expedia Properties
# could be changed to verify Room Types
use eanprod;
SELECT activepropertylist.EANHotelID,Name,RoomTypeID,RoomTypeDescription from activepropertylist 
JOIN roomtypelist
ON activepropertylist.EANHotelID=roomtypelist.EANHotelID
WHERE SupplierType="ESR"
# adding GROUP BY will present ONLY the first room
GROUP BY EANHotelID;
