@ECHO OFF
REM #################################################################################
REM ## Process tested in Windows 7 and SQL Express 2012 SP1                        ##
REM ## You will need to install the following utilities:                           ##
REM http://sourceforge.net/projects/getgnuwin32/files/latest/download?source=files ##
REM  Download GetGnuWin32-0.6.3.exe (3.4 MB) and the unzip.exe                     ##
REM ## -> wget                                                                     ##
REM ## -> unzip                                                                    ##
REM you will need to rename them, and place it in the same dir as this .bat        ##
REM #################################################################################

REM ### Environment ###
:: Store start time
set StartTIME=%TIME%
set H=%StartTIME:~0,2%
if "%H:~0,1%"==" " set H=%H:~1,1%
if "%H:~0,1%"=="0" set H=%H:~1,1%
set M=%StartTIME:~3,2%
if "%M:~0,1%"=="0" set M=%M:~1,1%
set S=%StartTIME:~6,2%
if "%S:~0,1%"=="0" set S=%S:~1,1%
set U=%StartTIME:~9,2%
if "%U:~0,1%"=="0" set U=%U:~1,1%
)
set /a Start100S=%H%*360000+%M%*6000+%S%*100+%U%

SET MSSQL_DIR=C:\
REM # for simplicity I added the MYSQL bin path to the Windows 
REM # path environment variable, for Windows set it to ""

REM #MySQL user, password, host (Server)
SET MSSQL_USER=eanuser
SET MSSQL_PASS=Passw@rd1
REM Connect to the Database Engine by specifying:
REM instance name: -S ComputerA\instance
REM ip address   : -S 127.0.0.1\instance
REM TCP/IP       : -S 127.0.0.1,1433
REM named pipes  : -S np:\\<computer name>\<pipe name>
SET MSSQL_ENGINE=localhost\SQLEXPRESS2012

SET MSSQL_DB=eanprod
REM home directory is where this script is running
REM and the required wget.exe and unzip.exe
SET HOME_DIR=C:\Users\jarce\eanRefresh
REM directory under HOME_DIR
SET FILES_DIR=%HOME_DIR%\eanfiles
REM .XML BCP Format files location
SET BCPXML_DIR=%HOME_DIR%\bcpxml
REM ### Import files ###
REM #####################################
REM # the list should match the tables ##
REM # created by create_ean.sql script ##
REM #####################################
REM the list should be filename{space}[shift-6]
REM last 8-files are to support minorRev=25 added files
SET FILES=ActivePropertyList ^
AirportCoordinatesList ^
AliasRegionList ^
AreaAttractionsList ^
AttributeList ^
ChainList ^
CityCoordinatesList ^
CountryList ^
DiningDescriptionList ^
GDSAttributeList ^
GDSPropertyAttributeLink ^
HotelImageList ^
NeighborhoodCoordinatesList ^
ParentRegionList ^
PointsOfInterestCoordinatesList ^
PolicyDescriptionList ^
PropertyAttributeLink ^
PropertyDescriptionList ^
PropertyTypeList ^
RecreationDescriptionList ^
RegionCenterCoordinatesList ^
RegionEANHotelIDMapping ^
RoomTypeList ^
SpaDescriptionList ^
WhatToExpectList ^
PropertyLocationList ^
PropertyAmenitiesList ^
PropertyRoomsList ^
PropertyBusinessAmenitiesList ^
PropertyNationalRatingsList ^
PropertyFeesList ^
PropertyMandatoryFeesList ^
PropertyRenovationsList

REM home where the process will execute
cd %HOME_DIR%

echo "Starting at working directory..."
echo %cd%
REM create subdirectory if required
IF EXIST %FILES_DIR%\NUL GOTO YESWORKDIR
echo "creating download files directory..."
mkdir %FILES_DIR%

:YESWORKDIR

REM move into the working directory
cd %FILES_DIR%

REM Download Data ###
echo "Downloading files using wget..."
REM for {each item} in {a collection of items} do {command}
REM added -nv to wget, to suppress the SYSTEMWGETRC and syswgetrc variables display
for %%i in (%FILES%) do (
	ECHO "Working with file/table: %%i"
REM do not download unless timestamp is different than previous attempts
	%HOME_DIR%\wget  -t 30 --no-verbose -nd -N -nv http://www.ian.com/affiliatecenter/include/V2/%%i.zip
REM unzip overwriting existing, change content names to lowercase
	%HOME_DIR%\unzip -o %%i.zip
REM Connect to a SQL Server Express server, you must specify the server name and, 
REM if SQL Server Express is installed in a named instance, the instance name. 
REM By default, sqlcmd uses Windows Authentication. 
REM If you are connecting to the SQL Server Express server by using SQL Server Authentication,
REM you must also provide the logon information for connecting to the SQL Server Express server
REM @fromFile = 'C:\Users\jarce\activepropertylist_20130228.txt'
REM @formatFile = 'C:\Users\jarce\bcp_activepropertylist.xml'
	sqlcmd -U %MSSQL_USER% -P %MSSQL_PASS% -S %MSSQL_ENGINE% -d %MSSQL_DB% -Q "EXEC sp%%i @fromFile = '%FILES_DIR%\%%i.txt', @formatFile='%BCPXML_DIR%\%%i.xml'"
)
echo "uploading files done."
cd %HOME_DIR%

REM
REM
REM display endtime for the script
:: Get the end time
set StopTIME=%TIME%
set H=%StopTIME:~0,2%
if "%H:~0,1%"==" " set H=%H:~1,1%
if "%H:~0,1%"=="0" set H=%H:~1,1%
set M=%StopTIME:~3,2%
if "%M:~0,1%"=="0" set M=%M:~1,1%
set S=%StopTIME:~6,2%
if "%S:~0,1%"=="0" set S=%S:~1,1%
set U=%StopTIME:~9,2%
if "%U:~0,1%"=="0" set U=%U:~1,1%
)

set /a Stop100S=%H%*360000+%M%*6000+%S%*100+%U%

:: Test midnight rollover. If so, add 1 day=8640000 1/100ths secs
if %Stop100S% LSS %Start100S% set /a Stop100S+=8640000
set /a TookTime=%Stop100S%-%Start100S%

echo Started: %StartTime%
echo Stopped: %StopTime%
echo Elapsed: %TookTime:~0,-2%.%TookTime:~-2% seconds
