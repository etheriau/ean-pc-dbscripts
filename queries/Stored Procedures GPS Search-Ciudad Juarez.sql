## Cuidad Juarez GPS (31.739444,-106.486944)
use eanprod;
## this will search in a radius mixing US and MX data
call sp_hotels_from_point(31.739444,-106.486944,10);
## this will show only Ciudad Juarez - MX
#call sp_hotels_from_point_restrict(31.739444,-106.486944,10,'MX','Ciudad Juarez');
## this will show ONLY El Paso - US
#call sp_hotels_from_point_restrict(31.739444,-106.486944,10,'US','El Paso');
## this will show ONLY for PostalCode "79901"
#call sp_hotels_from_point_restrict_zip(31.739444,-106.486944,10,"79901");

