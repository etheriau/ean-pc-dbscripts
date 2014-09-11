#Script to list properties and their Categories
# like Resort, Apt-Hotel, etc.
use eanprod;
select EANHotelID,Name,City,StateProvince,activepropertylist.PropertyCategory,PropertyCategoryDesc
FROM activepropertylist
LEFT JOIN propertytypelist
ON activepropertylist.PropertyCategory = propertytypelist.PropertyCategory
;
