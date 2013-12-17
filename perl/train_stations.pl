#!/opt/local/bin/perl -w
# SCRIPT TO CREATE TABLE WITH POSSIBLE TRAIN STATIONS
# cd /Users/jarce/Dropbox/EAN/DEV/ean-pc-dbscripts/perl
# FOR VENERE PROPERTIES

use strict;
use DBI;

# MYSQL CONFIG VARIABLES
# The hostname, if not specified or specified as '' or 'localhost', will default to a MySQL server running on the local machine using the default for the UNIX socket. 
# To connect to a MySQL server on the local machine via TCP, you must specify the loopback IP address (127.0.0.1) as the host.
my $host = '127.0.0.1';
my $port=8889;
#my $user = 'eanprod';
#my $pw = 'Passw@rd1';
my $user = 'root';
my $pw = 'root';

my $database = 'eanprod';
my $tablename = 'activepropertylist';

# DATA SOURCE NAME
my $dsn = "DBI:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# PRINT HEADER
print "EANHotelID|HotelName|Latitude|Longitude|HotelCountry|IATACode|AirportName|AirportISOCountry|AirportLatitude|AirportLongitude|DistanceToAirport\n";

#DEFINE ARRAY OF COUNTRIES TO SEARCH TRAIN STATIONS
# DEFINE AN ARRAY WITHOUT QUOTES
my @railCountries = qw(GB NL BE ES IT FR);
print "@railCountries";
while (@railCountries) {
   	my $railCountry = shift(@railCountries);
   	print "$railCountry\n";

	# DEFINE A MySQL QUERY
	my $query = "SELECT EANHotelID,Name,Latitude,Longitude,Country FROM eanprod.activepropertylist WHERE Country='$railCountry' AND EANHotelID=286020";
	my $countryList = $dbh->prepare($query);

	# EXECUTE THE QUERY
	$countryList->execute();
	
	while(my $RowcountryList = $countryList->fetchrow_hashref()) {

# EXTRACT RECORD VALUES
   		my $EANHotelID = "$RowcountryList->{EANHotelID}";
   		my $HotelName  = "$RowcountryList->{Name}";
   		my $Latitude   = "$RowcountryList->{Latitude}";
   		my $Longitude  = "$RowcountryList->{Longitude}";
   		my $Country    = "$RowcountryList->{Country}";
  		printf "$EANHotelID | $HotelName | $Latitude | $Longitude | $Country\n";

# CALL STORED PROCEDURE
   		my $sth = $dbh->prepare('CALL eanextras.sp_geonames_from_point_featcode(?,?,1,"MTRO");');
   		$sth->bind_param(1, $Latitude);
   		$sth->bind_param(2, $Longitude);
   		$sth->execute();
      	use Data::Dumper;
        $Data::Dumper::Useqq = 1;
        my $sth = Dumper( { $RowMetro } );
        print "$sht";
		if ($sth->rows > 0){
   			while(my $RowMetro = $sth->fetchrow_hashref()) {
      			#my $MetroGeoNameID = "$RowMetro->{GeoNameID}";
      			#my $MetroAsciiName = "$RowMetro->{AsciiName}";
      			#my $MetroLatitude  = "$RowMetro->{Latitude}";
      			#my $MetroLongitude = "$RowMetro->{Longitude}";
      			#my $MetroDistance  = "$RowMetro->{distance}";
      	# PRINT ROW OF DATA PER EACH RAIL STATION FOUND / IF FOUND IN 1 MILE
      			#printf "$EANHotelID|$HotelName|$Latitude|$Longitude|$Country|";
      			#printf "$MetroGeoNameID|$MetroAsciiName|$MetroLatitude|$MetroLongitude|$MetroDistance";
      			#printf "\n";
   			} # while Metro from Stored Procedure
   		} # if records      
	} # while Properties for that Country
} # List of Countries

#CLOSE THE DATABASE CONNECTION
my $rc = $dbh->disconnect();

# END