# Script to match the content that used to be in the Destinationids Downloadable files
# it covers various groups of Cites, and vicinities, Neighboorhoods and Multi regions content
use eanprod;
select * from parentregionlist
# Regular Cites as defines on ISO standards + 'and Vicinity' are Expedia expanded selling marketing regions
# hotels that are NOT technical in that city but people will like to stay
WHERE ( (parentregionlist.RegionType IN ('City','Multi-City (Vicinity)') AND parentregionlist.SubClass='') OR
# regional & Neighbothood names like Manhattan and Nighboorhoods in Europe 
		(parentregionlist.RegionType IN ('City','Neighborhood') AND parentregionlist.SubClass='regional') OR
# Multi-regions covers a mix of regions it includes Islands, West something, North something, Basque Country, etc
		(parentregionlist.RegionType='Multi-Region (within a country)')
) 
;