#!/opt/local/bin/perl -w
# SCRIPT TO CREATE TABLE WITH POSSIBLE NEARBY AIRPORT
# FOR VENERE PROPERTIES

use strict;
use DBI;

print "working to find Airports for Venere Properties";

# MYSQL CONFIG VARIABLES
my $host = "pincheserver";
my $database = "eanprod";
my $port=3306;
my $tablename = "activepropertylist";
my $user = "eanprod";
my $pw = "Passw\@rd1";
# DATA SOURCE NAME
my $dsn = "dbi:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# DEFINE A MySQL QUERY
my $query = "SELECT EANHotelID,Latitude,Longitude,Country FROM eanprod.activepropertylist WHERE SupplierType='EEM' LIMIT 10";
my $query_handle = $dbh->prepare($query);

# EXECUTE THE QUERY
my $query_handle->execute();

my $rownumber = $query_handle->numrows();
my $fieldnumber = $query_handle>numfields();

# PRINT THE RESULTS
printf( $rownumber);
printf( $fieldnumber);

#CLOSE THE DATABASE CONNECTION
my $rc = $dbh->disconnect;
