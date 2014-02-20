SELECT activepropertylist.EANHotelID,activepropertylist.Name,propertyattributelink.AttributeID,
           attributelist.Type,attributelist.SubType,attributelist.AttributeDesc,propertyattributelink.AppendTxt as Value
    FROM activepropertylist
    JOIN propertyattributelink
    ON activepropertylist.EANHotelID = propertyattributelink.EANHotelID 
    JOIN attributelist
    ON propertyattributelink.AttributeID = attributelist.AttributeID
    WHERE attributelist.AttributeID="51" ORDER BY EANHotelID;
