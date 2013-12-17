use eanprod;
select AirportCode, COUNT(*) as AmountOfHotels 
from activepropertylist
GROUP BY AirportCode;