# Lets join all data from static files to create a similar 
# as ActivePropertyList.SupplierType="ESR" - Expedia Collect
Select HotelID,Name
FROM (
	SELECT 1 AS grp,HotelID,Name from expediaactive where MarketingLevel = 2
UNION ALL
	SELECT 2 AS grp,HotelID,Name from vacationrentalsactive where MarketingLevel=2
UNION ALL
	SELECT 3 AS grp,HotelID,Name from venereactive where MarketingLevel=2
) AS t  
Group by HotelID;
