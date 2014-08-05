#!/opt/local/bin/perl -w
# SCRIPT TO CREATE FILE WITH ADDRESS OF HOTELS
# BASED ON REVERSE GEOCODING USIN OPENSTREETMAP DATA
# 
#

use strict;
use DBI;
use REST::Client;
use JSON;
use utf8;

# enable UTF-8 output
binmode(STDOUT, ":utf8");

# MYSQL CONFIG VARIABLES
# The hostname, if not specified or specified as '' or 'localhost', will default to a MySQL server running on the local machine using the default for the UNIX socket. 
# To connect to a MySQL server on the local machine via TCP, you must specify the loopback IP address (127.0.0.1) as the host.
my $host = 'pincheserver';
my $port=3306;
my $user = 'eanuser';
my $pw = 'Passw@rd1';
my $database = 'eanprod';
my $tablename = 'activepropertylist';

# Nominatim (OpenStreetMap.org) REST Service
# as documented: http://wiki.openstreetmap.org/wiki/Nominatim
# used to reversegeo call passing lat,long of the hotel
# by now using details=0 to keep in as a single line response
my $base_uri = "http://nominatim.openstreetmap.org";
# Creates an object for REST Client using Base URI
my $client = REST::Client->new({ host => $base_uri });

# DATA SOURCE NAME
my $dsn = "DBI:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# PRINT HEADER
print "EANHotelID|HotelName|Address1|Address2|City|StateProvince|PostalCode|Country|Latitude|Longitude|RealAddress\n";

# DEFINE A MySQL QUERY
my $query = "select EANHotelID,Name,Address1,Address2,City,StateProvince,PostalCode,Country,Latitude,Longitude from activepropertylist WHERE Country='MX' LIMIT 10";
my $hotel = $dbh->prepare($query);

# EXECUTE THE QUERY
$hotel->execute();
while(my $Rowhotel = $hotel->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $EANHotelID 	 = "$Rowhotel->{EANHotelID}";
   my $HotelName 	 = "$Rowhotel->{Name}";
   my $Address1 	 = "$Rowhotel->{Address1}";
   my $Address2 	 = "$Rowhotel->{Address2}";
   my $City 		 = "$Rowhotel->{City}";
   my $StateProvince = "$Rowhotel->{StateProvince}";
   my $PostalCode 	 = "$Rowhotel->{PostalCode}";
   my $Country 		 = "$Rowhotel->{Country}";
   my $Latitude 	 = "$Rowhotel->{Latitude}";
   my $Longitude 	 = "$Rowhotel->{Longitude}";

   printf "$EANHotelID|$HotelName|$Address1|$Address2|$City|$StateProvince|$PostalCode|$Country|$Latitude|$Longitude|$Country|";

   # CALL Nominatim (OpenStreetMap.org) Web Service
   if ($Latitude ne '' && $Longitude ne '') {
		$client->GET("/reverse?format=json&lat=$Latitude&lon=$Longitude&zoom=18&addressdetails=0");
		my $jsonobj = JSON::from_json($client->responseContent);
		# Prints the Address contained in the 'display_name'
		print $jsonobj->{'display_name'} . "\n";
        } else {
        printf "no values\n"; 
        }
} # while properties

#CLOSE THE DATABASE CONNECTION
my $rc = $dbh->disconnect();

# END