#!/bin/bash
#########################################################################
## Process tested in Windows, using Cygwin                             ##
## other than the default of the instalation you will need to install: ##
## -> wget                                                             ##
## -> unzip                                                            ##
## -> database client MySQL                                            ##
## you can select by searching for them in the Cygwin packages during  ##
## the install.                                                        ##
#########################################################################

### Environment ###
STARTTIME=$(date +%s)
## for Linux: CHKSUM_CMD=md5sum
## cksum should be available in all Unix versions
CHKSUM_CMD=md5sum
MYSQL_DIR=/usr/bin/
# for simplicity I added the MYSQL bin path to the Windows 
# path environment variable, for Windows set it to ""
#MYSQL_DIR=""
#MySQL user, password, host (Server)
MYSQL_USER=eanuser
MYSQL_PASS=Passw@rd1
MYSQL_HOST=localhost
MYSQL_DB=eanprod
# home directory of the user (in our case "eanuser")
HOME_DIR=/home/eanuser
# protocol TCP All, SOCKET Unix only, PIPE Windows only, MEMORY Windows only
MYSQL_PROTOCOL=SOCKET
# 3336 as default,MAC using MAMP is 8889
MYSQL_PORT=3306
## directory under HOME_DIR
FILES_DIR=eanfiles
## retention period in DAYS for the log of ActivePropertyList changes
LOG_DAYS=30

## Import files ###
#####################################
# the list should match the tables ##
# created by create_ean.sql script ##
#####################################
#LANG=es_ES
FILES=(
ActivePropertyList
AirportCoordinatesList
AliasRegionList
AreaAttractionsList
AttributeList
ChainList
CityCoordinatesList
CountryList
DiningDescriptionList
GDSAttributeList
GDSPropertyAttributeLink
HotelImageList
NeighborhoodCoordinatesList
ParentRegionList
PointsOfInterestCoordinatesList
PolicyDescriptionList
PropertyAttributeLink
PropertyDescriptionList
PropertyTypeList
RecreationDescriptionList
RegionCenterCoordinatesList
RegionEANHotelIDMapping
RoomTypeList
SpaDescriptionList
WhatToExpectList
#
# minorRev=25 added files
#
PropertyLocationList
PropertyAmenitiesList
PropertyRoomsList
PropertyBusinessAmenitiesList
PropertyNationalRatingsList
PropertyFeesList
PropertyMandatoryFeesList
PropertyRenovationsList
#
# To Add a language set, use this as a reference
#
#ActivePropertyList_es_ES
#AliasRegionList_es_ES
#AreaAttractionsList_es_ES
#AttributeList_es_ES
#CountryList_es_ES
#DiningDescriptionList_es_ES
#PolicyDescriptionList_es_ES
#PropertyAttributeLink_es_ES
#PropertyDescriptionList_es_ES
#PropertyTypeList_es_ES
#RecreationDescriptionList_es_ES
#RegionList_es_ES
#RoomTypeList_es_ES
#SpaDescriptionList_es_ES
#WhatToExpectList_es_ES
#PropertyLocationList_es_ES
#PropertyAmenitiesList_es_ES
#PropertyRoomsList_es_ES
#PropertyBusinessAmenitiesList_es_ES
#PropertyNationalRatingsList_es_ES
#PropertyFeesList_es_ES
#PropertyMandatoryFeesList_es_ES
#PropertyRenovationsList_es_ES
)

## home where the process will execute
#cd C:/data/EAN/DEV/database
## this will be CRONed so it needs the working directory absolute path
## change to your user home directory
cd ${HOME_DIR}

echo "Starting at working directory..."
pwd
## create subdirectory if required
if [ ! -d ${FILES_DIR} ]; then
   echo "creating download files directory..."
   mkdir ${FILES_DIR}
fi

## all clear, move into the working directory
cd ${HOME_DIR}

echo "Starting at working directory..."
pwd
## create subdirectory if required
if [ ! -d ${FILES_DIR} ]; then
   echo "creating download files directory..."
   mkdir ${FILES_DIR}
fi

## all clear, move into the working directory
cd ${FILES_DIR}

### Parameters that you may need:
### If you use LOW_PRIORITY, execution of the LOAD DATA statement is delayed until no other clients are reading from the table.
CMD_MYSQL="${MYSQL_DIR}mysql  --local-infile=1 --default-character-set=utf8 --protocol=${MYSQL_PROTOCOL} --port=${MYSQL_PORT} --user=${MYSQL_USER} --pass=${MYSQL_PASS} --host=${MYSQL_HOST} --database=${MYSQL_DB}"

### Download Data ###
echo "Downloading files using wget..."
for FILE in ${FILES[@]}
do
    ## capture the current file checksum
	if [ -e ${FILE}.txt ]; then
		echo "File exist $FILE.txt... saving checksum for comparison..."
    	CHKSUM_PREV=`$CHKSUM_CMD $FILE.txt | cut -f1 -d' '`
    else
    	CHKSUM_PREV=0
	fi
    ## download the files via HTTP (no need for https), using time-stamping, -nd no host directories
    wget  -t 30 --no-verbose -r -N -nd http://www.ian.com/affiliatecenter/include/V2/$FILE.zip
	## unzip the files, save the exit value to check for errors
	## BSD does not support same syntax, but there is no need in MAC OS as Linux (unzip -L `find -iname $FILE.zip`)
    unzip -L -o $FILE.zip
	ZIPOUT=$?
    ## rename files to CamelCase format
    mv `echo $FILE | tr \[A-Z\] \[a-z\]`.txt $FILE.txt
    ## special fix for DiningDescriptionLIst naming error
    if [ $FILE = "DiningDescriptionList" ] && [ -f "DiningDescriptionLIst.txt" ]; then
       mv -f DiningDescriptionLIst.txt diningdescriptionlist.txt
    fi
   	## some integrity tests to avoid processing 'bad' files
   	CHKSUM_NOW=`$CHKSUM_CMD $FILE.txt | cut -f1 -d' '`
    records=`wc -l < $FILE.txt | tr -d ' '`
    (( records-- ))
    ## check if we need to update or not based on file changed, file contains at least 1x record
    ## file is readeable, file NOT empty, file unzipped w/o errors
    if [ "$ZIPOUT" -eq 0 ] && [ "$CHKSUM_PREV" != "$CHKSUM_NOW" ] && [ "$records" -gt 0 ] && [ -s ${FILE}.txt ] && [ -r ${FILE}.txt ]; then
    	echo "Updating as integrity is ok & checksum change ($CHKSUM_PREV) to ($CHKSUM_NOW) on file ($FILE.txt)..."
		## table name are lowercase
   		tablename=`echo $FILE | tr "[[:upper:]]" "[[:lower:]]"`
        ## checking if working with activepropertylist to make a backup of it before changes
        if [ $tablename = "activepropertylist" ]; then
			echo "Running a backup of ActivePropertyList..."
			### Run stored procedures as required for extra functionality       ###
			### you can use this section for your own stuff                     ###
			CMDSP_MYSQL="${MYSQL_DIR}mysql  --default-character-set=utf8 --protocol=${MYSQL_PROTOCOL} --port=${MYSQL_PORT} --user=${MYSQL_USER} --pass=${MYSQL_PASS} --host=${MYSQL_HOST} --database=eanprod"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_createcopy();"
			echo "ActivePropertyList backup done."
        fi
		### Update MySQL Data ###
   		echo "Uploading ($FILE.txt) to ($MYSQL_DB.$tablename) with REPLACE option..."
		## let's try with the REPLACE OPTION
   		$CMD_MYSQL --execute="LOAD DATA LOCAL INFILE '$FILE.txt' REPLACE INTO TABLE $tablename CHARACTER SET utf8 FIELDS TERMINATED BY '|' IGNORE 1 LINES;"
   		## we need to erase the records, NOT updated today
   		echo "erasing old records from ($tablename)..."
   		$CMD_MYSQL --execute="DELETE FROM $tablename WHERE datediff(TimeStamp, now()) < 0;"
        ## checking if working with activepropertylist to fill the changed log table
        if [ $tablename = "activepropertylist" ]; then
			echo "Creating log of changes for ActivePropertyList..."
			### Run stored procedures as required for extra functionality       ###
			### you can use this section for your own stuff                     ###
			CMDSP_MYSQL="${MYSQL_DIR}mysql  --default-character-set=utf8 --protocol=${MYSQL_PROTOCOL} --port=${MYSQL_PORT} --user=${MYSQL_USER} --pass=${MYSQL_PASS} --host=${MYSQL_HOST} --database=eanprod"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_addedrecords();"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_erasedrecords();"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_erase_common();"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_erase_deleted();"
			$CMDSP_MYSQL --execute="CALL eanprod.sp_log_changedrecords();"
			### erase records before retention period
			$CMDSP_MYSQL --execute="DELETE FROM log_activeproperty_changes WHERE TimeStamp < DATE_SUB(NOW(), INTERVAL $LOG_DAYS DAY);"
			echo "Log for ActivePropertyList done."
        fi
    fi
done
echo "Updates done."

echo "Running Stored Procedures..."
### Run stored procedures as required for extra functionality       ###
### you can use this section for your own stuff                     ###
CMD_MYSQL="${MYSQL_DIR}mysql  --default-character-set=utf8 --protocol=${MYSQL_PROTOCOL} --port=${MYSQL_PORT} --user=${MYSQL_USER} --pass=${MYSQL_PASS} --host=${MYSQL_HOST} --database=eanextras"
$CMD_MYSQL --execute="CALL eanextras.sp_fill_fasttextsearch();"
echo "Stored Procedures done."


echo "Verify database against files..."
### Verify entries in tables against files ###
CMD_MYSQL="${MYSQL_DIR}mysqlshow --count ${MYSQL_DB} --protocol=${MYSQL_PROTOCOL} --port=${MYSQL_PORT} --user=${MYSQL_USER} --pass=${MYSQL_PASS} --host=${MYSQL_HOST}"
$CMD_MYSQL

### find the amount of records per datafile
### should match to the amount of database records
echo "+---------------------------------+----------+------------+"
echo "|             File                |       Records         |"
echo "+---------------------------------+----------+------------+"
for FILE in ${FILES[@]}
do
## to count the number of output records minus the header
##    records=$(($(wc -l $FILE.txt | awk '{print $1}')-1))
   records=`wc -l < $FILE.txt | tr -d ' '`
   (( records-- ))
   { printf "|" && printf "%33s" $FILE && printf "|" && printf "%23d" $records && printf "|\n"; }
done
echo "+---------------------------------+----------+------------+"
echo "Verify done."


echo "script (import_db.sh) done."

## display endtime for the script
ENDTIME=$(date +%s)
secs=$(( $ENDTIME - $STARTTIME ))
h=$(( secs / 3600 ))
m=$(( ( secs / 60 ) % 60 ))
s=$(( secs % 60 ))
printf "total script time: %02d:%02d:%02d\n" $h $m $s
