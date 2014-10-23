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


# MYSQL CONFIG VARIABLES
# The hostname, if not specified or specified as '' or 'localhost', will default to a MySQL server running on the local machine using the default for the UNIX socket. 
# To connect to a MySQL server on the local machine via TCP, you must specify the loopback IP address (127.0.0.1) as the host.
my $host = 'pincheserver';
my $port=3306;
my $user = 'eanuser';
my $pw = 'Passw@rd1';
my $database = 'eanextras';
my $tablename = 'destinationid_list';

# establish the Percentage that must be over to attempt a match 
my $lowpercent = .500;
my $highpercent = 500;

# DATA SOURCE NAME
my $dsn = "DBI:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# PRINT HEADER
print "DestinationID|DestinationName|DestinationCNT|MatchPercent|RegionCNT|RegionID|RegionNameLong|RegionType|RegionSubClass\n";

# DEFINE A MySQL QUERY
my $query = "SELECT destinationid_list.DestinationID,CONCAT_WS(',',Destination,StateProvince,Country) AS 'DestinationName',";
$query .= "DestinationCNT,DestinationHotelList FROM destinationid_list"; 
$query .= " JOIN destinationids ON destinationid_list.DestinationID = destinationids.DestinationID";
$query .=" WHERE DestinationHotelList <> ''";
$query .=" ORDER BY Destinationid";
$query .= " LIMIT 10";
my $DestinationQry = $dbh->prepare($query);

# EXECUTE THE QUERY
$DestinationQry->execute();
while(my $RowDestination = $DestinationQry->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $DestinationID = "$RowDestination->{DestinationID}";
   my $DestinationCNT = "$RowDestination->{DestinationCNT}";
   my $DestinationName = "$RowDestination->{DestinationName}";
   my $DestinationList = "$RowDestination->{DestinationHotelList}";

# query to get the possible matches of destination
   my $lowCNT  = $DestinationCNT - (( 1 - $lowpercent) * $DestinationCNT);
   my $highCNT = $DestinationCNT + abs(( 1 - $highpercent) * $DestinationCNT);

#   my $RegionIDMatch = check($DestinationID);
# DEFINE the MySQL QUERY to obtain possible matches
	my $query2 = "SELECT RegionID,RegionNameLong,eanprod.HOTELS_IN_REGION_COUNT(RegionID) AS 'HotelCNT',eanprod.HOTELS_IN_REGION(RegionID) as 'HotelList',";
	$query2 .= " RegionType,SubClass";
	$query2 .= " FROM eanprod.parentregionlist"; 
	$query2 .= " WHERE RegionType NOT IN('Point of Interest','Point of Interest Shadow','Continent','Country')"; 
	$query2 .= " AND eanprod.HOTELS_IN_REGION_COUNT(RegionID) >= $lowCNT AND eanprod.HOTELS_IN_REGION_COUNT(RegionID) <= $highCNT";
	$query2 .= " ORDER BY eanprod.HOTELS_IN_REGION_COUNT(RegionID) DESC";
	#$query2 .= " LIMIT 10";
	my $SetQry = $dbh->prepare($query2);
	
	# EXECUTE THE QUERY
	$SetQry->execute();
	while(my $RowSet = $SetQry->fetchrow_hashref()) {
	# EXTRACT RECORD VALUES
   		my $RegionID = "$RowSet->{RegionID}";
   		my $RegionName = "$RowSet->{RegionNameLong}";
   		my $RegionType = "$RowSet->{RegionType}";
   		my $RegionSubClass = "$RowSet->{SubClass}";
   		my $RegionCNT = "$RowSet->{HotelCNT}";
   		my $RegionHotelList = "$RowSet->{HotelList}";

		# check the difference of the sets, report in percentages
		my $likeness = check_diff( $DestinationList,$RegionHotelList);
# print the result line, only if at least one of the images fail to verify
        if ($likeness > 0) {        
            $likeness = sprintf("%.4f", $likeness); 
		    printf "$DestinationID|$DestinationName|$DestinationCNT|$likeness|$RegionCNT|$RegionID|$RegionName|$RegionType|$RegionSubClass\n";
        } else {
        #    printf "$DestinationID|$DestinationName|$DestinationCNT|$likeness\n";
        } #if/else
	} #while records in query2
	

} # while records in the query

#CLOSE THE DATABASE CONNECTION
	my $rc = $dbh->disconnect();

# END

###############################################################
# subroutine to check for amount of inventory of the given DestinationID
sub check_diff {
  my($set1, $set2);	# new, private variables for this block
  ($set1, $set2) = @_;	# give names to the parameters
my (@a1, @a2, $tot, $percnt, %diff1, %diff2);
# create the arrays and sort them
@a1 = sort split(',', $set1);
@a2 = sort split(',', $set2);
$tot = (scalar @a1) + (scalar @a2);
@diff1{ @a1 } = @a1;
delete @diff1{ @a2 };
# %diff1 contains elements from '@a1' that are not in '@a2'

@diff2{ @a2 } = @a2;
delete @diff2{ @a1 };
# %diff2 contains elements from '@a2' that are not in '@a1'

my @k = (keys %diff1, keys %diff2);
#print "keys = @k\n";
if (($tot - (scalar @k)) == 0) {
	return 0;
} else {
    return ($tot - (scalar @k)) / $tot;
} # if/else
} # end sub check_diff
################################################################
