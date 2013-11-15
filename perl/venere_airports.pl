#!/opt/local/bin/perl -w
# SCRIPT TO CREATE TABLE WITH POSSIBLE NEARBY AIRPORT
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

# DEFINE A MySQL QUERY
my $query = "SELECT EANHotelID,Name,Latitude,Longitude,Country FROM eanprod.activepropertylist WHERE SupplierType='EEM'";
my $Venere = $dbh->prepare($query);

# EXECUTE THE QUERY
$Venere->execute();
while(my $RowVenere = $Venere->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $EANHotelID = "$RowVenere->{EANHotelID}";
   my $HotelName = "$RowVenere->{Name}";
   my $Latitude = "$RowVenere->{Latitude}";
   my $Longitude = "$RowVenere->{Longitude}";
   my $Country = "$RowVenere->{Country}";
#  printf "$EANHotelID | $HotelName | $Latitude | $Longitude | $Country\n";

   # CALL STORED PROCEDURE
   my $sth = $dbh->prepare('CALL eanextras.sp_airport_from_ourairports(?,?,?,2);');
   $sth->bind_param(1, $Latitude);
   $sth->bind_param(2, $Longitude);
   $sth->bind_param(3, $Country);
   $sth->execute();

   while(my $RowAirport = $sth->fetchrow_hashref()) {
      my $AirIATACode = "$RowAirport->{IATACode}";
      my $AirAirportName = "$RowAirport->{AirportName}";
      my $AirISOCountry = "$RowAirport->{ISOCountry}";
      my $AirLatitude = "$RowAirport->{Latitude}";
      my $AirLongitude = "$RowAirport->{Longitude}";
      my $AirDistance = "$RowAirport->{distance}";
      # PRINT ROW OF DATA PER EACH AIRPORT FOUND / MOST OF THE TIME 2x LINES
      printf "$EANHotelID|$HotelName|$Latitude|$Longitude|$Country|";
      printf "$AirIATACode|$AirAirportName|$AirISOCountry|$AirLatitude|$AirLongitude|$AirDistance";
      printf "\n";
   } # while Airports from Stored Procedure      
} # while Venere properties

#CLOSE THE DATABASE CONNECTION
my $rc = $dbh->disconnect();

# END