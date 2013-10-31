/***************************************************************************/
/* Stored Procedures to Refresh ALL eanprod Database Tables			v 2.8  */
/* USAGE:																   */
/*-------------------------------------------------------------------------*/
/* CHANGE the FROM.txt and the FORMAT.xml FILE path - BEFORE USING IT!     */
/*-------------------------------------------------------------------------*/
/* This script use the new SQL Server 2008,2008 R2 and 201new MERGE        */
/* statement: http://technet.microsoft.com/en-us/library/bb510625.aspx     */
/*                                                                         */
/* ANSI_WARNINGS are turned off, to avoid errors with WIDECHAR conversions */
/* THIS SCRIPT WORKS WITH Microsoft SQL 2008, 2008 R2 and 2012             */
/* any engine, even the EXPRESS Version.                                   */
/*                                                                         */
/* For Microsoft SQL 2005 you can use and UPSERT like command, read here:  */
/* http://samsaffron.com/blog/archive/2007/04/04/14.aspx                   */
/***************************************************************************/
use eanprod
GO
CREATE PROCEDURE spActivePropertyList @fromFile nvarchar(1000), @formatFile nvarchar(1000)
AS
SET ANSI_WARNINGS OFF
MERGE eanprod.dbo.activepropertylist AS Target
USING (SELECT * FROM OPENROWSET(BULK 'C:\Users\jarce\eanRefresh\eanfiles\ActivePropertyList.txt',
       FORMATFILE = 'C:\Users\jarce\eanRefresh\bcpxml\ActivePropertyList.xml', FIRSTROW = 2) AS BCP) AS Source
-- primary key to find matching records
ON Target.EANHotelID = Source.EANHotelID
-- UPDATE RECORD
WHEN MATCHED THEN UPDATE SET Target.SequenceNumber = Source.SequenceNumber, Target.Name = Source.Name, Target.Address1 = Source.Address1, 
	 Target.Address2 = Source.Address2, Target.City = Source.City, Target.StateProvince = Source.StateProvince, Target.PostalCode = Source.PostalCode,
	 Target.Country = Source.Country, Target.Latitude = Source.Latitude, Target.Longitude = Source.Longitude, Target.AirportCode = Source.AirportCode, 
	 Target.PropertyCategory = Source.PropertyCategory, Target.PropertyCurrency = Source.PropertyCurrency, Target.StarRating = Source.StarRating, 
	 Target.Confidence = Source.Confidence, Target.SupplierType = Source.SupplierType, Target.Location = Source.Location,
	 Target.ChainCodeID = Source.ChainCodeID, Target.RegionID = Source.RegionID, Target.HighRate= Source.HighRate, Target.LowRate = Source.LowRate,
	 Target.CheckInTime = Source.CheckInTime, Target.CheckOutTime = Source.CheckOutTime 
-- INSERT RECORD
WHEN NOT MATCHED BY Target 
	THEN INSERT(EANHotelID, SequenceNumber, Name, Address1, Address2, City,
	        StateProvince, PostalCode, Country, Latitude, Longitude, AirportCode,
			PropertyCategory, PropertyCurrency, StarRating, Confidence, SupplierType,
			Location, ChainCodeID, RegionID, HighRate, LowRate, CheckInTime, CheckOutTime) 
	VALUES(Source.EANHotelID, Source.SequenceNumber, Source.Name, Source.Address1, Source.Address2, 
	       Source.City, Source.StateProvince, Source.PostalCode, Source.Country, Source.Latitude, 
		   Source.Longitude, Source.AirportCode, Source.PropertyCategory, Source.PropertyCurrency,
		   Source.StarRating, Source.Confidence, Source.SupplierType, Source.Location, Source.ChainCodeID,
		   Source.RegionID, Source.HighRate, Source.LowRate, Source.CheckInTime, Source.CheckOutTime)
-- DELETE RECORD
WHEN NOT MATCHED BY Source THEN DELETE
-- UNCOMMENT to report UPDATE, DELETE and INSERT operations
/* OUTPUT $action, 
   DELETED.EANHotelID AS TargetEANHotelID,  
   INSERTED.EANHotelID AS SourceEANHotelID; 
  SELECT @@ROWCOUNT
*/
;
-- turn WARNINGS back on						
SET ANSI_WARNINGS ON
GO
