# Attributes for an Hotel in (es_es)
SELECT propertyattributelink.AttributeID,attributelist.AttributeDesc,
       attributelist_es_es.AttributeDesc as AttributeDesc_es_es,AppendTxt as Value,Type,SubType 
FROM propertyattributelink
JOIN attributelist
ON propertyattributelink.AttributeID=attributelist.AttributeID
JOIN attributelist_es_es
ON attributelist.AttributeID=attributelist_es_es.AttributeID
WHERE EANHotelID=262633;
