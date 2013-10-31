## create the Spatial table
use eanextras;
DROP TABLE IF EXISTS geohotels;
CREATE TABLE geohotels
(
	EANHotelID INT NOT NULL,
    Location point NOT NULL,
	PRIMARY KEY (EANHotelID)
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_unicode_ci;
## create the spatial index
CREATE SPATIAL INDEX idx_spatial_geohotels 
                  ON geohotels (Location);


## fill the table
use eanextras;
truncate geohotels;
INSERT INTO geohotels (EANHotelID, Location)
  SELECT EANHotelID, GeomFromText((CONCAT('POINT(',TRIM(Longitude)," ",TRIM(Latitude),')')))
  FROM eanprod.activepropertylist;

## query using a box 5 sequence points

SELECT geohotels.EANHotelID, activepropertylist.Name, activepropertylist.City, activepropertylist.Country 
FROM eanextras.geohotels
JOIN eanprod.activepropertylist
ON geohotels.EANHotelID = activepropertylist.EANHotelID 
WHERE MBRContains(GeomFromText('Polygon((0 0,0 10,3 10,3 0,0 0))'),geohotels.Location);
