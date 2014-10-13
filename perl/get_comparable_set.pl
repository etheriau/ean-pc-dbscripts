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
my $host = '127.0.0.1';
my $port=3306;
my $user = 'eanuser';
my $pw = 'Passw@rd1';
my $database = 'eanextras';
my $tablename = 'destinationid_list';

# establish the Percentage that must be over to attempt a match 
my $percent = .50

# DATA SOURCE NAME
my $dsn = "DBI:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# PRINT HEADER
print "DestinationID|RegionID|MatchPercentage\n";

# DEFINE A MySQL QUERY
my $query = "SELECT DestinationID,DestinationCNT,DestinationHotelList FROM destinationid_list ORDER BY Destinationid LIMIT 1";
my $DestinationQry = $dbh->prepare($query);

# EXECUTE THE QUERY
$DestinationQry->execute();
while(my $RowDestination = $DestinationQry->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $DestinationID = "$RowDestination->{DestinationID}";
   my $DestinationCNT = "$RowDestination->{DestinationCNT}";
   my $DestinationList = "$RowDestination->{DestinationHotelList}";

# query to get the possible matches of destination
   my lowCNT = DestinationCNT - (( 1 - $percentage) * DestinationCNT)
   my highCNT =  DestinationCNT + (( 1 - $percentage) * DestinationCNT)

#   my $RegionIDMatch = check($DestinationID);
   sleep(1);

# print the result line, only if at least one of the images fail to verify 
		printf "$DestinationID|$DestinationCNT|$lowCNT|$highCNT\n";

} # while records in the query

#CLOSE THE DATABASE CONNECTION
	my $rc = $dbh->disconnect();

# END

###############################################################
# subroutine to check for amount of inventory of the given DestinationID
sub check_diff {
  my(@set1, @set2);	# new, private variables for this block
  (@set1, @set2) = @_;	# give names to the parameters
my @a1, @a2, %diff1, %diff2;
@a1 = (1, 5, 10, 15);
@a2 = (5, 15, 25);

@diff1{ @a1 } = @a1;
delete @diff1{ @a2 };
# %diff1 contains elements from '@a1' that are not in '@a2'

@diff2{ @a2 } = @a2;
delete @diff2{ @a1 };
# %diff2 contains elements from '@a2' that are not in '@a1'

@k = (keys %diff1, keys %diff2);
print "keys = @k\n";
    return @k;
} # end sub check_diff
################################################################
