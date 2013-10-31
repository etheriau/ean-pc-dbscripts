#search for a specific big city
use eanextras;
select * from geonames 
WHERE AsciiName="Genova" and CountryCode="IT" and
FeatureClass="P" and FeatureCode="PPLA";


