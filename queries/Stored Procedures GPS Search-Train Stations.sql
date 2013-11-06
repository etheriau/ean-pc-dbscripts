## Serach using stored procedure for GeoNames Data
## you need to see the FEATURE CLASS & FEATURE CODE to undestand the results
## http://www.geonames.org/export/codes.html
##  to get that info, so a search for:
## EXAMPLE IS: 286020 – Carin Hotel (London) GPSPoint ( 51.51274,-0.18305)
use eanextras;
#call sp_geonames_from_point(51.51274,-0.18305,1);
## now if we are more specific about the Feature Class/Code we can search for Train Stations
## MTRO	metro station	metro station (Underground, Tube, or Metro) 
call sp_geonames_from_point_featcode(51.51274,-0.18305,1,"MTRO");
