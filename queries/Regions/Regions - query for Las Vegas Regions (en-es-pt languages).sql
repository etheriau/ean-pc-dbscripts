#query for a Region by Name, with its translation in Spanish ahd Portuguese
use eanprod;
SELECT parentregionlist.RegionID,parentregionlist.RegionNameLong as 'English',
regionlist_es_es.RegionNameLong as 'Spanish',regionlist_pt_br.RegionNameLong as 'Portuguese'
FROM parentregionlist
JOIN regionlist_es_es ON parentregionlist.RegionID = regionlist_es_es.RegionID
JOIN regionlist_pt_br ON parentregionlist.RegionID = regionlist_pt_br.RegionID
WHERE parentregionlist.RegionNameLong LIKE "%Las Vegas%";


