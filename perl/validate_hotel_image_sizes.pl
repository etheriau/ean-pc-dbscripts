#!/usr/bin/perl -w
# Perl Script to validate the URLs of ALL possible EAN Images and
# save the 'real size' by reading the actual image header
#  
#image_type 	Prefix 	Name 		Code 	width 	height 	type
#Still Image 	None 	Big 		_b 	350 	350 	Variable
#Still Image 	None 	Landscape 	_l 	255 	144 	Fixed
#Still Image 	None 	Small 		_s 	200 	200 	Variable
#Still Image 	None 	thumb 		_t 	70 	70 	Fixed
#Still Image 	None 	90X90f 		_n 	90 	90 	Fixed
#Still Image 	None 	140X140f 	_g 	140 	140 	Fixed
#Still Image 	None 	180x180f 	_d 	180 	180 	Fixed
#Still Image 	None 	500X500v 	_y 	500 	500 	Variable
#Still Image 	None 	1000X1000v 	_z 	1000 	1000 	Variable
#
 
# will be used to validate the URLs in the Database files
#
# You will need the LWP library use command to install
#
# sudo perl -MCPAN -e 'install Bundle::LWP'
use strict;
use LWP::Simple;
use Image::Size;
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

# array list of images sizes to test
my @listToTest = ('b','l','s','t','n','g','d','y','z');

# PRINT HEADER
print "EANHotelID|SizeType|URL|Width|Height\n";

# DEFINE A MySQL QUERY
my $query = "SELECT EANHotelID,URL FROM hotelimagelist ORDER BY EANHotelID;";
my $ImagesURL = $dbh->prepare($query);

# EXECUTE THE QUERY
$ImagesURL->execute();
while(my $RowImagesURL = $ImagesURL->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $EANHotelID = "$RowImagesURL->{EANHotelID}";
   my $URL = "$RowImagesURL->{URL}";

# loop over all possible images sizes
   for my $imagetype_element (@listToTest) {
   
# check if images are valid using LWP library
      my $imageURL = substr($URL, 0, -5) .$imagetype_element. ".jpg";   
      my $verifyURL = &img_check($imageURL);

# check the true image size
      my $width= 0;
      my $height = 0;
      if ($verifyURL==1) {
         # download the image into a file
         my $rc = getstore($imageURL, 'imagetotest.jpg');
         if (is_error($rc)) {
            die "getstore of <$imageURL> failed with HTTP status code: $rc";
         } # error downloading the image
         # now get the size
         ($width, $height) = imgsize('imagetotest.jpg');
         # print the result line, for URL image
         printf "$EANHotelID|$imagetype_element|$imageURL|$width|$height\n";
      } # if verified to be there



   } # for all images sizes

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
