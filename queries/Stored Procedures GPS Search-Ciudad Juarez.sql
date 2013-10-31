## Cuidad Juarez GPS (-106.486944,31.739444)
use eanprod;
## this will search in a radius mixing US and MX data
call sp_hotels_from_point(-106.486944,31.739444,10);
## this will show only Ciudad Juarez - MX
#call sp_hotels_from_point_restrict(-106.486944,31.739444,10,'MX','Ciudad Juarez');
## this will show ONLY El Paso - US
#call sp_hotels_from_point_restrict(-106.486944,31.739444,10,'US','El Paso');
