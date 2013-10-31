use eanprod;
SELECT EANHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,
		Latitude,Longitude,AirportCode,PropertyCategory,PropertyCurrency,
		SupplierType,Location,ChainCodeID,CheckInTime,CheckOutTime
FROM (
SELECT EANHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,
		Latitude,Longitude,AirportCode,PropertyCategory,PropertyCurrency,
		SupplierType,Location,ChainCodeID,CheckInTime,CheckOutTime
FROM activepropertylist AS Newest
UNION ALL
SELECT EANHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,
		Latitude,Longitude,AirportCode,PropertyCategory,PropertyCurrency,
		SupplierType,Location,ChainCodeID,CheckInTime,CheckOutTime
FROM oldactivepropertylist AS Oldest
) AS t
GROUP BY EANHotelID,EANHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,
		Latitude,Longitude,AirportCode,PropertyCategory,PropertyCurrency,
		SupplierType,Location,ChainCodeID,CheckInTime,CheckOutTime
# count of 1 will reflect new records and updated records
# count of 2 will reflect data is the same
HAVING COUNT(*) = 2
ORDER BY EANHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,
		Latitude,Longitude,AirportCode,PropertyCategory,PropertyCurrency,
		SupplierType,Location,ChainCodeID,CheckInTime,CheckOutTime