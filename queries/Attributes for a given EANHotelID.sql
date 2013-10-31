# Attributes for an Hotel
SELECT propertyattributelink.AttributeID,attributelist.AttributeDesc,
       AppendTxt as Value,Type,SubType 
FROM propertyattributelink
JOIN attributelist
ON propertyattributelink.AttributeID=attributelist.AttributeID
WHERE EANHotelID=262633;
