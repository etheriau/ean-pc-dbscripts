SELECT gdspropertyattributelink.AttributeID,AttributeDesc,AppendTxt as Value,Type,SubType 
FROM gdspropertyattributelink 
JOIN gdsattributelist ON gdspropertyattributelink.AttributeID=gdsattributelist.AttributeID 
WHERE EANHotelID=31576 and gdspropertyattributelink.LanguageCode='en_US';