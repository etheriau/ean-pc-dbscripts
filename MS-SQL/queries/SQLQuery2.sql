USE eanprod;
GO
if exists (select * from sys.objects where name = 'activepropertylist' and type = 'u')
   drop table activepropertylist
GO
CREATE TABLE activepropertylist
(
	EANHotelID INT NOT NULL,
	SequenceNumber INT,
	Name NVARCHAR(70),
	Address1 NVARCHAR(50),
	Address2 NVARCHAR(50),
	City NVARCHAR(50),
	StateProvince NCHAR(2),
	PostalCode NVARCHAR(15),
	Country NCHAR(2),
	Latitude numeric(8,5),
	Longitude numeric(8,5),
	AirportCode NCHAR(3),
	PropertyCategory INT,
	PropertyCurrency NCHAR(3),
	StarRating numeric(2,1),
	Confidence INT,
	SupplierType NCHAR(3),
	Location NVARCHAR(80),
	ChainCodeID NCHAR(5),
	RegionID INT,
	HighRate numeric(19,4),
	LowRate numeric(19,4),
	CheckInTime NCHAR(10),
	CheckOutTime NCHAR(10),
    TimeStamp rowversion,
	PRIMARY KEY (EANHotelID)
)
GO