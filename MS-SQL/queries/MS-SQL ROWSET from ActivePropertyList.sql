SELECT * 
FROM OPENROWSET(BULK 'C:\Users\jarce\activepropertylist.txt',FORMATFILE='C:\Users\jarce\bcp_activepropertylist.xml', FIRSTROW = 2) AS bcp_activepropertylist
ORDER BY bcp_activepropertylist.EanHotelID;
