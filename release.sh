#!/bin/bash


PUBLIC_DIR=public
RELEASE_DIR=release

FTP_RELEASE_DIR=release
FTP_SERVER=ftps://alfa3055.alfahosting-server.de

FTP_USER=web191f3
FTP_PASSWORD=Korztnacka1608$

VIDEO_DIR=video
IMAGE_DIR=images
PUBLIC_VIDEO_DIR=$PUBLIC_DIR/$VIDEO_DIR
PUBLIC_IMAGE_DIR=$PUBLIC_DIR/$IMAGE_DIR


VERSION_FILE=version
RELEASE_DATE_FILE=release_date
SCRIPT_FILE=install.php
INSTALL_SCRIPT_FILE=$RELEASE_DIR/$SCRIPT_FILE
INSTALL_SCRIPT_KEY=#123##999#
INSTALL_SCRIPT_URL=http://www.ajka-andrej.com/$FTP_RELEASE_DIR/$SCRIPT_FILE?key=$INSTALL_SCRIPT_KEY

THIS_MONTH_DIR=$(date +"%Y/%m")
LAST_MONTH_DIR=$(date --date='-1 month' +"%Y/%m")

RELEASE_DATE=$(date +"%Y%m%d%H%M")
RELEASE_FILE=$RELEASE_DIR/release_$RELEASE_DATE.zip

VERSION=$(git rev-parse HEAD)

echo "Current version: $(curl -s http://www.ajka-andrej.com/$VERSION_FILE)"
echo "Current release date: $(curl -s http://www.ajka-andrej.com/$RELEASE_DATE_FILE)"
echo "New version: $VERSION"
echo "New release date: $RELEASE_DATE"

read -p "Do you want to install new version? [y/n] " -n 1 -r
echo 
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi


echo "0. Create public directory"
rm -rf $PUBLIC_DIR
hugo --theme=hugo-icarus-theme --i18n-warnings

echo "1. Create the $PUBLIC_DIR/$VERSION_FILE info file"
echo $VERSION > $PUBLIC_DIR/$VERSION_FILE

echo "2. Create the $PUBLIC_DIR/$RELEASE_DATE_FILE info file"
echo $RELEASE_DATE > $PUBLIC_DIR/$RELEASE_DATE_FILE

echo "3. Remove the $RELEASE_DIR directory"
rm -rf $RELEASE_DIR

echo "4. Create the $RELEASE_DIR directory"
mkdir $RELEASE_DIR

echo "5. Start creating the release package $RELEASE_FILE"
cd $PUBLIC_DIR
zip -r ../$RELEASE_FILE ./* -x ./wp-content\* ./images\* ./video\* > $RELEASE_FILE.log
cd ..
echo "6. The release package was created $RELEASE_FILE"

echo "7. Create the instalation script"
echo "<?php" \
"\$key = \$_GET['key'];" \
"if (\$key == '$INSTALL_SCRIPT_KEY') {" \
"    \$path = getcwd();" \
"    \$zip = new ZipArchive;" \
"    \$res = \$zip->open('$FILE');" \
"    if (\$res === TRUE) { echo $path.'/../test';" \
"         //\$zip->extractTo(\$path.'/../test');" \
"         //\$zip->close();" \	
"         echo 'OK';" \
"    } else {" \
"        echo 'ERROR';" \
"    }" \
"} else {" \
"    echo 'ERROR';" \
"}" \
"?>" > $INSTALL_SCRIPT_FILE

echo "8. Synchronize last two months of the videos and images"
if [ -d "$PUBLIC_DIR/$IIMAGE_DIR/$THIS_MONTH_DIR" ]; then
  duck --username $FTP_USER --password $FTP_PASSWORD --existing upload --synchronize $FTP_SERVER/$IMAGE_DIR/$THIS_MONTH_DIR
else
  echo "The $IMAGE_DIR/$THIS_MONTH_DIR directory does not exists. No need to synchronize $PUBLIC_DIR/$IMAGE_DIR/$THIS_MONTH_DIR"
fi

if [ -d "$PUBLIC_DIR/$IMAGE_DIR/$LAST_MONTH_DIR" ]; then
  duck --username $FTP_USER --password $FTP_PASSWORD --existing upload --synchronize $FTP_SERVER/$IMAGE_DIR/$LAST_MONTH_DIR
else
  echo "The $IMAGE_DIR/$LAST_MONTH_DIR directory does not exists. No need to synchronize $PUBLIC_DIR/$IMAGE_DIR/$LAST_MONTH_DIR"
fi

if [ -d "$PUBLIC_DIR/$VIDEO_DIR/$THIS_MONTH_DIR" ]; then
  duck --username $FTP_USER --password $FTP_PASSWORD --existing upload --synchronize $FTP_SERVER/$VIDEO_DIR/$THIS_MONTH_DIR
else
  echo "The $VIDEO_DIR/$THIS_MONTH_DIR directory does not exists. No need to synchronize $PUBLIC_DIR/$VIDEO_DIR/$THIS_MONTH_DIR"
fi

if [ -d "$PUBLIC_DIR/$VIDEO_DIR/$LAST_MONTH_DIR" ]; then
  duck --username $FTP_USER --password $FTP_PASSWORD --existing upload --synchronize $FTP_SERVER/video/$LAST_MONTH_DIR
else
 echo "The $VIDEO_DIR/$LAST_MONTH_DIR directory does not exists. No need to synchronize $PUBLIC_DIR/$IMAGE_DIR/$LAST_MONTH_DIR"
fi

echo "9. Upload release to FTP $RELEASE_FILE -> $FTP_SERVER"
duck --username $FTP_USER --password $FTP_PASSWORD --upload $FTP_SERVER/$FTP_RELEASE_DIR $RELEASE_FILE

echo "10. Upload install script to FTP $INSTALL_SCRIPT_FILE -> $FTP_SERVER"
duck --username $FTP_USER --password $FTP_PASSWORD --upload $FTP_SERVER/$FTP_RELEASE_DIR $INSTALL_SCRIPT_FILE

echo "11. Execute the installation script $INSTALL_SCRIPT_FILE"
SCRIPT_STATUS=$(curl -s $INSTALL_SCRIPT_URL)
echo "Execution status: $SCRIPT_STATUS"

echo "12. Delete the installation script $INSTALL_SCRIPT_FILE"
duck --username $FTP_USER --password $FTP_PASSWORD --upload $FTP_SERVER/$FTP_RELEASE_DIR/*.php

echo "13. The new version successfully installed"
echo "------------------------------------------"
echo "New version: $(curl -s http://www.ajka-andrej.com/$VERSION_FILE)"
echo "New release date: $(curl -s http://www.ajka-andrej.com/$RELEASE_DATE_FILE)"
echo "------------------------------------------"

