## call sp_fill_chainlistlink();

	SELECT activepropertylist.EANHotelID, Name, 
	chainlist.ChainCodeID, ChainName
	FROM eanprod.activepropertylist 
	INNER JOIN eanprod.chainlist ON CONCAT(' ',LOWER(activepropertylist.Name),' ')
	LIKE BINARY CONCAT('% ',LOWER(eanprod.chainlist.ChainName),' %')
	WHERE (TRIM(IFNULL(activepropertylist.ChainCodeID,'')) = '')
	GROUP BY EANHotelID
;
