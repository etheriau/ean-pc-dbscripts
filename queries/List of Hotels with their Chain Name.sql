select activepropertylist.EANHotelID, activepropertylist.Name, chainlist.ChainName, activepropertylist.City, activepropertylist.Country 
from activepropertylist
INNER JOIN chainlist
ON activepropertylist.ChainCodeID = chainlist.ChainCodeID
ORDER BY ChainName;