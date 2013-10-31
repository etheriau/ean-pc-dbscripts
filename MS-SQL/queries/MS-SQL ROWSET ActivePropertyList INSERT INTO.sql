/********************************************************************/
/* Query to Refresh the activepropertylist Table					*/
/* will set ANSI_WARNINGS OFF to avoid truncation errors, as they	*/
/* reffer to datafiles containing WIDECHARACTERS					*/
/********************************************************************/
USE eanprod;
GO
SET ANSI_WARNINGS OFF
GO
INSERT INTO activepropertylist (EANHotelID, SequenceNumber, Name, Address1, Address2, City,
	        StateProvince, PostalCode, Country, Latitude, Longitude, AirportCode,
			PropertyCategory, PropertyCurrency, StarRating, Confidence, SupplierType,
			Location, ChainCodeID, RegionID, HighRate, LowRate, CheckInTime, CheckOutTime)
	SELECT EANHotelID, SequenceNumber, Name, Address1, Address2, City,
	        StateProvince, PostalCode, Country, Latitude, Longitude, AirportCode,
			PropertyCategory, PropertyCurrency, StarRating, Confidence, SupplierType,
			Location, ChainCodeID, RegionID, HighRate, LowRate, CheckInTime, CheckOutTime
	 FROM OPENROWSET(BULK 'C:\Users\jarce\activepropertylist.txt',
	                         FORMATFILE='C:\Users\jarce\bcp_activepropertylist.xml', FIRSTROW = 2) as BCP
							 
GO
SET ANSI_WARNINGS ON
