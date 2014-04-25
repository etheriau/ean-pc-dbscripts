#!/opt/local/bin/perl -w
# Perl Script to validate the URLs of Images (SIZE 1000x1000 _z)
# will be used to validate the URLs in the Database files
#
# You will need the LWP library use command to install
#
# sudo perl -MCPAN -e 'install Bundle::LWP'
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
my $database = 'eanprod';
my $tablename = 'activepropertylist';

# DATA SOURCE NAME
my $dsn = "DBI:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# PRINT HEADER
print "EANHotelID|URL|Verified\n";

# DEFINE A MySQL QUERY
my $query = "SELECT EANHotelID,URL FROM hotelimagelist ORDER BY EANHotelID;";
my $ImagesURL = $dbh->prepare($query);

# EXECUTE THE QUERY
$ImagesURL->execute();
while(my $RowImagesURL = $ImagesURL->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $EANHotelID = "$RowImagesURL->{EANHotelID}";
   my $URL = "$RowImagesURL->{URL}";

# check if images are valid using LWP library
    my $bigImageURL = substr($URL, 0, -5) . "z.jpg";   
	my $verifyURL = &img_check($bigImageURL);

# print the result line, only if the URL image (_z size) fail to verify
    if (not($verifyURL)) {
       $URL = substr($URL, 0, -5) . "z.jpg";  
		printf "$EANHotelID | $URL | $verifyURL\n";
	} # if 

} # while Images URLs in the query

#CLOSE THE DATABASE CONNECTION
	my $rc = $dbh->disconnect();

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