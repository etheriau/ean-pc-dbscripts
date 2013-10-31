/* Query to show amount of Hotel Names that are duplicated */
SELECT EANHotelID, Name, count(Name) AS NumOccurrences
FROM activepropertylist
GROUP BY Name HAVING count(Name) > 1; 