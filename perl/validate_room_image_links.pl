#!/opt/local/bin/perl -w
# Perl Script to validate the URLs of Images
# will be used to validate the URLs in the Database files
#
# You will need the LWP library, use this command to install
#
# sudo perl -MCPAN -e 'install Bundle::LWP'
use strict;
use LWP::Simple;
use DBI;

# MYSQL CONFIG VARIABLES
# The hostname, if not specified or specified as '' or 'localhost', will default to a MySQL server running on the local machine using the default for the UNIX socket. 
# To connect to a MySQL server on the local machine via TCP, you must specify the loopback IP address (127.0.0.1) as the host.
my $host = '172.16.18.188';
my $port=3306;
my $user = 'eanprod';
my $pw = 'Passw@rd1';
#my $host = '127.0.0.1';
#my $port=8889;
#my $user = 'root';
#my $pw = 'root';

my $database = 'eanprod';
my $tablename = 'activepropertylist';

# DATA SOURCE NAME
my $dsn = "DBI:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# PRINT HEADER
print "EANHotelID|RoomTypeID|RoomTypeName|RoomTypeImage|VerifiedURL\n";

# DEFINE A MySQL QUERY
my $query = "SELECT EANHotelID,RoomTypeID,RoomTypeName,RoomTypeImage FROM roomtypelist WHERE RoomTypeImage <> '' LIMIT 0,1000";
my $ImagesURL = $dbh->prepare($query);

# EXECUTE THE QUERY
$ImagesURL->execute();
my $counter = 0;
while(my $RowImagesURL = $ImagesURL->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $EANHotelID = "$RowImagesURL->{EANHotelID}";
   my $RoomTypeID = "$RowImagesURL->{RoomTypeID}";
   my $RoomTypeName = "$RowImagesURL->{RoomTypeName}";
   my $URL = "$RowImagesURL->{RoomTypeImage}";
   
   #jump to next record, if URL is empty
   if ($URL eq "")
   	{ next 
   	} # if empty URL

# check if images are valid using LWP library
	my $verifyURL = &img_check(substr($URL, 0, -3) . "jpg");

# print the result line, only if the image fail to verify
    if (not($verifyURL)) { 
		printf "$EANHotelID | $RoomTypeID | $RoomTypeName | $URL | $verifyURL\n";
		$counter++;
	} # if 

} # while Images URLs in the query

#CLOSE THE DATABASE CONNECTION
	my $rc = $dbh->disconnect();

printf "Records with problems: $counter\n";
# END

###############################################################
# subroutine to check if an image exist at a given URL
sub img_check {
	my $url = shift;
	# get type / length / modification date
	my ($type, $length, $mod) = head($url);
  	unless (defined $type) {
    	return 0;
  	}
	return 1;
} # end sub img_check
################################################################