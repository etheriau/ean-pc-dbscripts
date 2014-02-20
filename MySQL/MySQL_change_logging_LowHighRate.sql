##################################################################
# this version of the log_activeproperty changes
# checks ALSO the changes to the LowRate & HighRate fields
# 02/20/2014
##################################################################
use eanprod;

##################################################################
## STEP 1 - Save Old records
## must be called BEFORE refreshing activepropertylist
## will create a copy of activepropertylist 
## that we later use to analize what has changed
##################################################################
# creates the table the same as original so the LowRate / HighRate will be there
DROP PROCEDURE IF EXISTS sp_log_createcopy;
DELIMITER $$
CREATE PROCEDURE sp_log_createcopy()
BEGIN
DROP TABLE IF EXISTS oldactivepropertylist;
CREATE TABLE oldactivepropertylist LIKE eanprod.activepropertylist;
INSERT oldactivepropertylist SELECT * FROM eanprod.activepropertylist;
END 
$$
DELIMITER ;

##################################################################
## STEP 2 - add Added Records to log table
## must be called AFTER refreshing activepropertylist
## will classify as added / reactivated
##################################################################
DROP PROCEDURE IF EXISTS sp_log_addedrecords;
DELIMITER $$
CREATE PROCEDURE sp_log_addedrecords()
BEGIN
## save maximum EANHotelID from last run
## to identify if records are NEW ADDED or REACTIVATIONS
SELECT @max_eanid:=MAX(EANHotelID) FROM oldactivepropertylist;
#DECLARE mymaxid INT;
#SELECT MAX(EANHotelID)INTO mymaxid FROM oldactivepropertylist LIMIT 1,1;

## Identify Reactivated Records
## those that are NOT in the old-table
## 	EANHotelID,FieldName,FieldType,FieldValue,TimeStamp
INSERT INTO log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
SELECT NOW.EANHotelID,'EANHotelID' AS FieldName,'int' AS FieldType, NULL as FieldValueOld, 'reactivated record' as FieldValueNew
FROM oldactivepropertylist AS OLD
RIGHT JOIN activepropertylist AS NOW
ON OLD.EANHotelID=NOW.EANHotelID
WHERE OLD.EANHotelID IS NULL AND NOW.EANHotelID <= @max_eanid;

## Identify Newly Added Records
## those that are NOT in the old-table
## 	EANHotelID,FieldName,FieldType,FieldValue,TimeStamp
INSERT INTO log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
SELECT NOW.EANHotelID,'EANHotelID' AS FieldName,'int' AS FieldType, NULL as FieldValueOld, 'added record' as FieldValueNew
FROM oldactivepropertylist AS OLD
RIGHT JOIN activepropertylist AS NOW
ON OLD.EANHotelID=NOW.EANHotelID
WHERE OLD.EANHotelID IS NULL AND NOW.EANHotelID > @max_eanid;

END 
$$
DELIMITER ;

##################################################################
## STEP 3 - add Erased Records to log table
## must be called AFTER refreshing activepropertylist
##################################################################
DROP PROCEDURE IF EXISTS sp_log_erasedrecords;
DELIMITER $$
CREATE PROCEDURE sp_log_erasedrecords()
BEGIN
## Identify Deleted Records
## because they used to be in the old-table
## 	EANHotelID,FieldName,FieldType,FieldValue,TimeStamp
INSERT INTO log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
SELECT OLD.EANHotelID,'EANHotelID' AS FieldName,'int' AS FieldType, NULL as FieldValueOld, 'erased record' as FieldValueNew
FROM oldactivepropertylist AS OLD
LEFT JOIN activepropertylist AS NOW
ON OLD.EANHotelID=NOW.EANHotelID
WHERE NOW.EANHotelID IS NULL;
END 
$$
DELIMITER ;

##################################################################
## STEP 4 - Erase common records
## must be called AFTER refreshing activepropertylist
## will erase all records that are the same (based on an specific field list)
##################################################################
# here we add LowRate / HighRate so if they are different they will not be erased
DROP PROCEDURE IF EXISTS sp_log_erase_common;
DELIMITER $$
CREATE PROCEDURE sp_log_erase_common()
BEGIN
DELETE oldactivepropertylist
FROM oldactivepropertylist
JOIN activepropertylist
USING (EANHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,
		Latitude,Longitude,AirportCode,PropertyCategory,PropertyCurrency,
		SupplierType,Location,ChainCodeID,LowRate,HighRate,CheckInTime,CheckOutTime);
END
$$
DELIMITER ;

##################################################################
## STEP 5 - Erase deleted records (after logging them)
## must be called AFTER refreshing activepropertylist, and sp_log_erasedrecords
## will erase all records in old-table
##################################################################
DROP PROCEDURE IF EXISTS sp_log_erase_deleted;
DELIMITER $$
CREATE PROCEDURE sp_log_erase_deleted()
BEGIN
DELETE oldactivepropertylist
FROM oldactivepropertylist
LEFT JOIN activepropertylist
ON oldactivepropertylist.EANHotelID=activepropertylist.EANHotelID
WHERE activepropertylist.EANHotelID IS NULL;
END
$$
DELIMITER ;

##################################################################
## STEP 6 - Work with the changed records
## must be called AFTER refreshing activepropertylist
## analize the changed data, looping thru the available records
##################################################################
# we add processing for the LowRate & HighRate fields
DROP PROCEDURE IF EXISTS sp_log_changedrecords;
DELIMITER $$
CREATE PROCEDURE sp_log_changedrecords()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE oEANHotelID,oPropertyCategory INT;
  DECLARE oName VARCHAR(70);
  DECLARE oAddress1,oAddress2,oCity VARCHAR(50);
  DECLARE oStateProvince,oCountry VARCHAR(2);
  DECLARE oPostalCode VARCHAR(15);
  DECLARE oLatitude,oLongitude NUMERIC(8,5);
  DECLARE oAirportCode,oPropertyCurrency,oSupplierType VARCHAR(3);
  DECLARE oLocation VARCHAR(80);
  DECLARE oChainCodeID VARCHAR(5);
  DECLARE oHighRate,oLowRate NUMERIC(19,4);
  DECLARE oCheckInTime,oCheckOutTime VARCHAR(10);
  
  DECLARE nEANHotelID,nPropertyCategory INT;
  DECLARE nName VARCHAR(70);
  DECLARE nAddress1,nAddress2,nCity VARCHAR(50);
  DECLARE nStateProvince,nCountry VARCHAR(2);
  DECLARE nPostalCode VARCHAR(15);
  DECLARE nLatitude,nLongitude NUMERIC(8,5);
  DECLARE nAirportCode,nPropertyCurrency,nSupplierType VARCHAR(3);
  DECLARE nLocation VARCHAR(80);
  DECLARE nChainCodeID VARCHAR(5);
  DECLARE nHighRate,nLowRate NUMERIC(19,4);
  DECLARE nCheckInTime,nCheckOutTime VARCHAR(10);
  
  DECLARE cur CURSOR FOR SELECT o.EANHotelID,o.Name,o.Address1,o.Address2,o.City,o.StateProvince,o.PostalCode,o.Country,
		o.Latitude,o.Longitude,o.AirportCode,o.PropertyCategory,o.PropertyCurrency,
		o.SupplierType,o.Location,o.ChainCodeID,o.HighRate,o.LowRate,o.CheckInTime,o.CheckOutTime,
	    n.EANHotelID,n.Name,n.Address1,n.Address2,n.City,n.StateProvince,n.PostalCode,n.Country,
		n.Latitude,n.Longitude,n.AirportCode,n.PropertyCategory,n.PropertyCurrency,
		n.SupplierType,n.Location,n.ChainCodeID,n.HighRate,n.LowRate,n.CheckInTime,n.CheckOutTime FROM eanprod.oldactivepropertylist AS o
		LEFT JOIN activepropertylist AS n ON o.EANHotelID=n.EANHotelID;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO oEANHotelID,oName,oAddress1,oAddress2,oCity,oStateProvince,oPostalCode,oCountry,
		oLatitude,oLongitude,oAirportCode,oPropertyCategory,oPropertyCurrency,
		oSupplierType,oLocation,oChainCodeID,oHighRate,oLowRate,oCheckInTime,oCheckOutTime,
    	nEANHotelID,nName,nAddress1,nAddress2,nCity,nStateProvince,nPostalCode,nCountry,
		nLatitude,nLongitude,nAirportCode,nPropertyCategory,nPropertyCurrency,
		nSupplierType,nLocation,nChainCodeID,nHighRate,nLowRate,nCheckInTime,nCheckOutTime;
    IF done THEN
      LEAVE read_loop;
    END IF;
    IF oName != nName THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew) 
      VALUES (nEANHotelID,'Name','VARCHAR(70)',oName,nName);
    END IF;
    IF oAddress1 != nAddress1 THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew) 
      VALUES (nEANHotelID,'Address1','VARCHAR(50)',oAddress1,nAddress1);
    END IF;
    IF oAddress2 != nAddress2 THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Address2','VARCHAR(50)',oAddress2,nAddress2);
    END IF;
    IF oCity != nCity THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'City','VARCHAR(50)',oCity,nCity);
    END IF;
    IF oStateProvince != nStateProvince THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'StateProvince','VARCHAR(2)',oStateProvince,nStateProvince);
    END IF;
    IF oPostalCode != nPostalCode THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'PostalCode','VARCHAR(15)',oPostalCode,nPostalCode);
    END IF;
    IF oCountry != nCountry THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Country','VARCHAR(2)',oCountry,nCountry);
    END IF;
    IF oLatitude != nLatitude THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Latitude','NUMERIC(8,2)',oLatitude,nLatitude);
    END IF;
    IF oLongitude != nLongitude THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Longitude','NUMERIC(8,2)',oLongitude,nLongitude);
    END IF;
    IF oAirportCode != nAirportCode THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'AirportCode','VARCHAR(3)',oAirportCode,nAirportCode);
    END IF;
    IF oPropertyCategory != nPropertyCategory THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'PropertyCategory','INT',oPropertyCategory,nPropertyCategory);
    END IF;
    IF oPropertyCurrency != nPropertyCurrency THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'PropertyCurrency','VARCHAR(3)',oPropertyCurrency,nPropertyCurrency);
    END IF;
    IF oSupplierType != nSupplierType THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'SupplierType','VARCHAR(3)',oSupplierType,nSupplierType);
    END IF;
    IF oLocation != nLocation THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'Location','VARCHAR(80)',oLocation,nLocation);
    END IF; 
    IF oChainCodeID != nChainCodeID THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'ChainCodeID','VARCHAR(5)',oChainCodeID,nChainCodeID);
    END IF;
    IF oHighRate != nHighRate THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'HighRate','NUMERIC(19,4)',oHighRate,nHighRate);
    END IF;
    IF oLowRate != nLowRate THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'LowRate','NUMERIC(19,4)',oLowRate,nLowRate);
    END IF;
    IF oCheckInTime != nCheckInTime THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'CheckInTime','VARCHAR(10)',oCheckInTime,nCheckInTime);
    END IF;
    IF oCheckOutTime != nCheckOutTime THEN
      INSERT INTO eanprod.log_activeproperty_changes (EANHotelID,FieldName,FieldType,FieldValueOld,FieldValueNew)
      VALUES (nEANHotelID,'CheckOutTime','VARCHAR(10)',oCheckOutTime,nCheckOutTime);
    END IF;

  END LOOP;
  CLOSE cur;
END
$$
DELIMITER ;
