use eanextras;
DROP PROCEDURE IF EXISTS sp_fill_venere_airports;
DELIMITER $$
CREATE PROCEDURE sp_fill_venere_airports()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cEANHotelID INT;
  DECLARE cAirportCode VARCHAR(3);
  DECLARE cCountryCode VARCHAR(2);
  DECLARE cLatitude,cLongitude NUMERIC(8,5);
    DECLARE cur CURSOR FOR SELECT EANHotelID,Latitude,Longitude,Country FROM eanprod.activepropertylist WHERE SupplierType='EEM';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO cEANHotelID,cLatitude,cLongitude,cCountryCode;
    IF done THEN
      LEAVE read_loop;
    END IF;
    INSERT INTO eanextras.venere_airports (EANHotelID,AirportCode,Distance) 
    VALUES ( SELECT cEANHotelID as EANHotelID,AirportCode,
	round( sqrt((POW(a.Latitude-cLatitude,2)*68.1*68.1)+(POW(a.Longitude-cLongitude,2)*53.1* 53.1))) AS distance
				 FROM eanprod.airportcoordinateslist AS a
				 WHERE CountryCode=cCountryCode
                ORDER BY distance ASC LIMIT 1);
  END LOOP;
  CLOSE cur;
END
$$
DELIMITER ;