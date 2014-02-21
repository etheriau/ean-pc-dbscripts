#!/usr/bin/perl -w
# Perl Script to extract PET POLICY FEES from propertyfeeslist
# will be used to validate the URLs in the Database files
#
# You will need the LWP library use command to install
#
# sudo perl -MCPAN -e 'install Bundle::LWP'
use HTML::TokeParser;
use strict;
use DBI;

# MYSQL CONFIG VARIABLES
# The hostname, if not specified or specified as '' or 'localhost', will default to a MySQL server running on the local machine using the default for the UNIX socket. 
# To connect to a MySQL server on the local machine via TCP, you must specify the loopback IP address (127.0.0.1) as the host.
my $host = '172.16.18.188';
my $port=3306;
my $user = 'eanuser';
my $pw = 'Passw@rd1';


my $database = 'eanprod';
my $tablename = 'propertyfeeslist';

# DATA SOURCE NAME
my $dsn = "DBI:mysql:$database:$host:$port";
my $dbh = DBI->connect($dsn, $user, $pw)  or die "Cannot connect to MySQL server\n";

# PRINT HEADER
print "EANHotelID|Type|Currency|Amount|Frequency\n";

# DEFINE A MySQL QUERY
my $query = "select EANHotelID,PropertyFeesDescription from propertyfeeslist where PropertyFeesDescription LIKE '%pet%'";
my $PetFee = $dbh->prepare($query);

# EXECUTE THE QUERY
$PetFee->execute();
while(my $RowPetFee = $PetFee->fetchrow_hashref()) {
# EXTRACT RECORD VALUES
   my $EANHotelID = "$RowPetFee->{EANHotelID}";
   my $htmlfees = "$RowPetFee->{PropertyFeesDescription}";
   
   my $lineoftext = "";
   my $currency = "";
   my $amount="";
 
   #parsing from an UTF-8 encoded string, decoding it first
   utf8::decode($htmlfees);
   my $stream = HTML::TokeParser->new(\$htmlfees);
 
   while (my $token = $stream->get_token) {
      if ($token->[0] eq 'T') { # T=text
      # process the text in $token->[1]
        $lineoftext = $token->[1];
#      	if (index($lineoftext, "Pet fee:") != -1) {
		# regex to match Pet fee: ONLY at the begging of line & upper or lowercase
      	if ($lineoftext =~ /\A(?i)Pet fee:/) {
      	   printf "$EANHotelID|Fee|";
      	   # erase the "Pet Fee: " part
      	   $lineoftext =~ s/\A(?i)Pet fee: //;
      	   $currency=substr($lineoftext,0,index($lineoftext,' '));
      	   $lineoftext=substr($lineoftext,(index($lineoftext,' ')+1));
      	   print $currency . "|";
      	   $amount=substr($lineoftext,0,index($lineoftext,' '));
      	   $lineoftext=substr($lineoftext,(index($lineoftext,' ')+1));
      	   print $amount . "|";
      	   print $lineoftext;
      	   printf "\n";
      	}# if contains the 'Pet Fee'
      	if ($lineoftext =~ /\A(?i)Pet deposit:/) {
      	   printf "$EANHotelID|Deposit|";
      	   # erase the "Pet Deposit: " part
      	   $lineoftext =~ s/\A(?i)Pet Deposit: //;
      	   $currency=substr($lineoftext,0,index($lineoftext,' '));
      	   $lineoftext=substr($lineoftext,(index($lineoftext,' ')+1));
      	   print $currency . "|";
      	   $amount=substr($lineoftext,0,index($lineoftext,' '));
      	   $lineoftext=substr($lineoftext,(index($lineoftext,' ')+1));
      	   print $amount . "|";
      	   print $lineoftext;
      	   printf "\n";
      	}# if contains the 'Pet Deposit'
    } #if
   } #while

} # while Records in the query

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
