#!/usr/bin/perl -w
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
use Data::Dumper;

# MYSQL CONFIG VARIABLES
# The sing Jhostname, if not specified or specified as '' or 'localhost', will default to a MySQL server running on the local machine using the default for the UNIX socket. 
# To connect to a MySQL server on the local machine via TCP, you must specify the loopback IP address (127.0.0.1) as the host.
my $host = '172.16.18.188';
my $port=3306;
my $user = 'eanuser';
my $pw = 'Passw@rd1';
my $database = 'eanextras';
my $tablename = 'destinations';

# DATA SOURCE NAME
my $dsn = "DBI:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# PRINT HEADER
print "DestinationID|AmtOfProperties|ListOfProperties\n";

# DEFINE A MySQL QUERY
my $query = "SELECT DestinationID FROM destinationids ORDER BY DestinationID;";
my $DestinationQry = $dbh->prepare($query);

# EXECUTE THE QUERY
$DestinationQry->execute(); 
while(my $RowDestination = $DestinationQry->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $DestinationID = "$RowDestination->{DestinationID}";
# call the web service to get the list of hotels
   #my $AmtOfHotels = amt_check($DestinationID);
# call the web services (maybe multiple times) to get the list of hotel ids
   my $ListOfHotels = extract_hotelidlist($DestinationID);
   # calculate the amount of hotels from the list (to save calling the REST 2x times)
   my $AmtOfHotels = 0;
   if ($ListOfHotels ne '') {
      $AmtOfHotels = ($ListOfHotels =~ tr/,//) + 1;
  } #if   
   # wait so we do not 'hammer the API too strong and get a Mashery over quota error
   sleep(1);
# print the result line, only if at least one of the images fail to verify 
   printf "$DestinationID|$AmtOfHotels|$ListOfHotels\n";
} # while records in the query
#CLOSE THE DATABASE CONNECTION
my $rc = $dbh->disconnect();
# END

#sample call
#http://api.ean.com/ean-services/rs/hotel/v3/list?cid=55505&apiKey=66kyp9xunfdw38vxnfq6gthf&minorRev=99&locale=en_US&currencyCode=USD&options=HOTEL_SUMMARY&destinationId=0000E16E-2FD5-498B-B695-CEE491C47D33
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
    # check for no error response instead of zero ("verboseMessage":"No Response Available. ")
    if (!defined $decoded->{'HotelListResponse'}{'EanWsError'}{'verboseMessage'}) {
       $amt = $decoded->{'HotelListResponse'}{'HotelList'}{'@activePropertyCount'};
       } #if
    return $amt;
} # end sub amt_check

###############################################################
# subroutine to extract the list of eanhotelids for the given DestinationID
# currently support ONLY dateless search as it does NOT need to use the Cache-Key
# to make subsequent calls (DATELESS search returns all hotels in a single call)
#
sub extract_hotelidlist {
  my($destID);	# new, private variables for this block
  ($destID) = @_;	# give names to the parameters
    my $urlbase = 'http://api.ean.com/ean-services/rs/hotel/v3/list?';
    $urlbase .= 'cid=390309&apiKey=eq8spp2vdg5zxa7b7rx6hn5y&minorRev=99';
    $urlbase .= '&locale=en_US&currencyCode=USD&options=HOTEL_SUMMARY';
    my $url = $urlbase . "&destinationId=" . $destID;
    my $response = get $url;
    die 'Error getting $url' unless defined $response;
    my $decoded = decode_json($response);
    my $amt = 0;
    my $hotelidlist = '';
    # check for no error response instead of zero
    if (!defined $decoded->{'HotelListResponse'}{'EanWsError'}{'verboseMessage'}) {
       $amt = $decoded->{'HotelListResponse'}{'HotelList'}{'@activePropertyCount'};
       # parsing of 1x, else, array of results
       if ($amt == 1) {
	  $hotelidlist = $decoded->{'HotelListResponse'}{'HotelList'}{'HotelSummary'}{'hotelId'};
       } else {
          my @hotelidsarray;
	  # parsing of the "HotelSummary" array
          my @hotellist = @{ $decoded->{'HotelListResponse'}{'HotelList'}{'HotelSummary'} };
          foreach my $h ( @hotellist ) {
             #save ids in the array
             push(@hotelidsarray, int($h->{"hotelId"}) );
             $amt = $amt -1;
          } #foreach
          # sort the list of hotelIds
          my @sortedidsarray = sort { $a <=> $b } @hotelidsarray;
          #convert to comma delimited list
          $hotelidlist = join(',',@sortedidsarray);
       }#else-if
    } #if not error
    return $hotelidlist;
} # end sub extract_hotelidlist
################################################################
