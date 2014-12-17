#!/usr/bin/python
# -*- coding: utf-8 -*-
# python script to get EAN image ByteSize, Width and Height
# w/o downloading the whole image, will ONLY get the first 1024 bytes
# to determinate the size from the .jpg header
#
# Speed improvement:
# Using simple threadpool implementation, to ensures that there are
# no more than X jobs running at the same time
#
# it requires the MySQL hotelimagelist table
# could be changed to parse the hotelimagelist.txt file directly
#
# Table of Possible EAN Image Sizes
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
import sys
import httplib
import urlparse
import urllib
#to install PIL in CentOS use: yum install python-imaging
import ImageFile
# you will need to install the phyton driver to MySQL
import MySQLdb as mdb

    
##
# FUNCTION getJpgSizesFromUrl
# get file size *and* image size directly from URL
# w/o downloading the whole image, just a 1K block to get the
# .jpg header that contains the width, heigth info.
##
def getJpgSizesFromUrl(uri):
    file = urllib.urlopen(uri)
    # use content-length to know the bytesize
    size = file.headers.get("content-length")
    if size: size = int(size)
    # we parse as we receive the image (to avoid downloading it full)
    p = ImageFile.Parser()
    while 1:
        # ONLY read 1024 bytes of data, to get the jpg headers
        data = file.read(1024)
        if not data:
            return (None, (None,None))
            break
        p.feed(data)
        if p.image:
            return size, p.image.size
            break
    file.close()
    return size, (None, (None,None))


##
# MAIN PROGRAM BODY
##


    
# array of possible sizes
list_to_test = ('b','l','s','t','n','g','d','y','z')

# PRINT HEADER
print "EANHotelID|Caption|DefaultImage|URL|SizeType|Width|Height|ByteSize"
con = mdb.connect('localhost', 'eanuser', 'Passw@rd1', 'eanprod')
with con:
    cur = con.cursor(mdb.cursors.DictCursor)
    cur.execute("SELECT EANHotelID,Caption,DefaultImage,URL FROM hotelimagelist ORDER BY EANHotelID LIMIT 100;")

    rows = cur.fetchall()

    for row in rows:
        
        for size_to_test in list_to_test:
            # create image URL with size indicator to test
            imageURL = row["URL"][:-5]+size_to_test+'.jpg'          
            # get file size, width & height of the image.jpg
            # return either (577485, (2291, 1552)) or (None,(None, None)
            bytesize, (width,height) = getJpgSizesFromUrl(imageURL)
            if bytesize is not None:
                sys.stdout.write(str(row["EANHotelID"]) + '|' + row["Caption"] + '|' + str(row["DefaultImage"]) + '|')
                # current size type working on
                sys.stdout.write(imageURL +'|'+size_to_test+'|')
                sys.stdout.write("%d|%d|%d" % (bytesize, width, height))
                sys.stdout.write("\n")
        # end-for sizes to test
    #end-for SQL rows
# EOF: hotel_images_sizes.py
