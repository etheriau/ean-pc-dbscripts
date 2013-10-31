use eanextras;
select AirportCode, IATACode, AirportName, Municipality, ISOCountry
FROM airports 
WHERE IATACode = 'CDG' or IATACode='YUL' or IATACode='FCO' or IATACode='LHR';