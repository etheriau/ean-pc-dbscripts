## this query will show if the hotel focus is to (family, singles, couples)
## and also if they accept Pets or not)
SELECT activepropertylist.EANHotelID,Name,City,Country,
attributelist.AttributeDesc,attributelist.Type 
FROM activepropertylist,propertyattributelink,attributelist 
WHERE activepropertylist.EANHotelID = propertyattributelink.EANHotelID 
and propertyattributelink.AttributeID = attributelist.AttributeID 
and (attributelist.AttributeDesc LIKE '%Pets%' or 
attributelist.AttributeDesc LIKE '%Caters%');