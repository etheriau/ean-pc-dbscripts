## Search for airports using ourairports data
## VENERE properties does NOT have an assigned airport, using the our-airports-data we filter for the Internationals and largest regional airports
##  to get that info, so a search for:
## EXAMPLE IS: 286020 – Carin Hotel (London) GPSPoint ( 51.51274,-0.18305)
use eanextras;
call sp_airport_from_ourairports(51.51274,-0.18305,"GB",2);