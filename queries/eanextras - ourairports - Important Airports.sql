## ourairports data - Airports that are big enough
use eanextras;
select * from airports
WHERE AirportType='large_airport' AND IATACode<>'' AND ScheduledService='yes'
;