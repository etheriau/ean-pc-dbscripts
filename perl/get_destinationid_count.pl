#!/opt/local/bin/perl -w
# Perl Script to discover the amount of hotels for all Destinations table
# using the DestinationID
#
# You will need the LWP library use command to install
#
# sudo perl -MCPAN -e 'install Bundle::LWP'
# sudo perl -MCPAN -e 'install JSON' 
use strict;
use LWP::Simple;
use DBI;
use JSON;

# MYSQL CONFIG VARIABLES
# The hostname, if not specified or specified as '' or 'localhost', will default to a MySQL server running on the local machine using the default for the UNIX socket. 
# To connect to a MySQL server on the local machine via TCP, you must specify the loopback IP address (127.0.0.1) as the host.
my $host = '127.0.0.1';
my $port=3306;
my $user = 'eanuser';
my $pw = 'Passw@rd1';
my $database = 'eanprod';
my $tablename = 'destinations';

# DATA SOURCE NAME
my $dsn = "DBI:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# PRINT HEADER
print "DestinationID|AmtOfProperties\n";

# DEFINE A MySQL QUERY
my $query = "SELECT DestinationID FROM destinationids ORDER BY DestinationID LIMIT 2";
my $DestinationQry = $dbh->prepare($query);

# EXECUTE THE QUERY
$DestinationQry->execute();
while(my $RowDestination = $DestinationQry->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $DestinationID = "$RowDestination->{DestinationID}";
# call the web service to check the amt of records
   my $AmtOfHotels = amt_check($DestinationID);
   sleep(1);

# print the result line, only if at least one of the images fail to verify 
		printf "$DestinationID|$AmtOfHotels\n";

} # while records in the query

#CLOSE THE DATABASE CONNECTION
	my $rc = $dbh->disconnect();

# END

###############################################################
# subroutine to check for amount of inventory of the given DestinationID
sub amt_check {
  my($destID);	# new, private variables for this block
  ($destID) = @_;	# give names to the parameters
	my $url = 'http://api.ean.com/ean-services/rs/hotel/v3/list?';
    $url .= 'cid=390309&apiKey=eq8spp2vdg5zxa7b7rx6hn5y&minorRev=99';
    $url .= '&locale=en_US&currencyCode=USD&options=HOTEL_SUMMARY';
    $url .= "&destinationId=" . $destID;
    my $response = get $url;
    die 'Error getting $url' unless defined $response;
    my $decoded = decode_json($response);
    my $amt = 0;
    # check for no error response instead of zero
    if (!defined $decoded->{'HotelListResponse'}{'EanWsError'}{'verboseMessage'}) {
       $amt = $decoded->{'HotelListResponse'}{'HotelList'}{'@activePropertyCount'};
       } #if
    return $amt;
} # end sub amt_check
################################################################
#Sample API call
#http://api.ean.com/ean-services/rs/hotel/v3/list?cid=55505&apiKey=66kyp9xunfdw38vxnfq6gthf&minorRev=99&locale=en_US&currencyCode=USD&options=HOTEL_SUMMARY&destinationId=0000E16E-2FD5-498B-B695-CEE491C47D33
