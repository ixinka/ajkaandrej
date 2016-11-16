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


THIS_MONTH_DIR=$(date +"%Y/%m")
LAST_MONTH_DIR=$(date --date='-1 month' +"%Y/%m")

RELEASE_DATE=$(date +"%Y%m%d%H%M%S")
RELEASE_FILE=release_$RELEASE_DATE.zip

INSTALL_SCRIPT_URL=http://www.ajka-andrej.com/$FTP_RELEASE_DIR/$SCRIPT_FILE?key=$RELEASE_DATE

VERSION=$(git rev-parse HEAD)

# STATUS:
echo "----------------------------------------------------------"
echo " Status "
echo "----------------------------------------------------------"
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
echo "----------------------------------------------------------"

# CHECK CHANGES
echo ""
echo "----------------------------------------------------------"
echo " Check changes in the working directory "
echo "----------------------------------------------------------"
CHANGES=$(git status -s)
if [[ ! -z $CHANGES ]]
then
	echo "Cahnged files:"
	echo $CHANGES
	echo ""
	echo "Solution: Use the commit script to commit all changes in the repostiry."
	exit 0;
fi
echo "----------------------------------------------------------"

# BUILD PAGE
echo ""
echo "----------------------------------------------------------"
echo " Create public directory "
echo "----------------------------------------------------------"
rm -rf $PUBLIC_DIR
hugo --theme=hugo-icarus-theme --i18n-warnings --ignoreCache

echo " The public directory was created "
echo "----------------------------------------------------------"

# CREATE THE VERSION AND RELEASE FILE
echo ""
echo "----------------------------------------------------------"
echo " Create the $PUBLIC_DIR/$VERSION_FILE and $PUBLIC_DIR/$RELEASE_DATE_FILE info file"
echo "----------------------------------------------------------"
echo $VERSION > $PUBLIC_DIR/$VERSION_FILE
echo " The new version info file: $VERSION"
echo $RELEASE_DATE > $PUBLIC_DIR/$RELEASE_DATE_FILE
echo " The new release info file: $RELEASE_DATE"
echo "----------------------------------------------------------"

# CREATE RELEASE FILE
echo ""
echo "----------------------------------------------------------"
echo " Create the release $RELEASE_FILE file in the $RELEASE_DIR directory"
echo "----------------------------------------------------------"
rm -rf $RELEASE_DIR
mkdir $RELEASE_DIR
cd $PUBLIC_DIR
zip -r ../$RELEASE_DIR/$RELEASE_FILE ./* -x ./wp-content\* ./images\* ./video\* > zip.log
cd ..
echo " The release package was created $RELEASE_FILE"
echo "----------------------------------------------------------"

# CREATE SCRIPT FILE
echo ""
echo "----------------------------------------------------------"
echo " Create the instalation script $RELEASE_DIR/$SCRIPT_FILE file"
echo "----------------------------------------------------------"
echo "<?php
\$key = \$_GET['key'];
if (\$key == '$RELEASE_DATE') {
    \$path = getcwd();
    \$zip = new ZipArchive;
    \$res = \$zip->open('$RELEASE_FILE');
    if (\$res === TRUE) { 
         \$zip->extractTo(\$path.'/../');
         \$zip->close();
         echo 'OK';
    } else {
        echo 'ERROR';
    }
} else {
    echo 'ERROR';
}
?>
" > $RELEASE_DIR/$SCRIPT_FILE
echo " The script file $RELEASE_DIR/$SCRIPT_FILE was created."
echo "----------------------------------------------------------"

# SYNCHRONIZE VIDEO AND IMAGES
echo ""
echo "----------------------------------------------------------"
echo " Synchronize last two months of the videos and images"
echo "----------------------------------------------------------"
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
echo "----------------------------------------------------------"

# UPLOAD FILES
echo ""
echo "----------------------------------------------------------"
echo " Upload release file and script"
echo "----------------------------------------------------------"
echo " Upload release to FTP $RELEASE_DIR/$RELEASE_FILE -> $FTP_SERVER"
duck --username $FTP_USER --password $FTP_PASSWORD --upload $FTP_SERVER/$FTP_RELEASE_DIR/$RELEASE_FILE $RELEASE_DIR/$RELEASE_FILE
echo " Upload install script to FTP $RELEASE_DIR/$SCRIPT_FILE -> $FTP_SERVER"
duck --username $FTP_USER --password $FTP_PASSWORD --upload $FTP_SERVER/$FTP_RELEASE_DIR/$SCRIPT_FILE $RELEASE_DIR/$SCRIPT_FILE

# EXECUTE THE INSTALLATION SCRIPT
echo ""
echo "----------------------------------------------------------"
echo " Execute the installation script $RELEASE_DIR/$SCRIPT_FILE"
SCRIPT_STATUS=$(curl -s $INSTALL_SCRIPT_URL)
echo "Execution status: $SCRIPT_STATUS"
echo "----------------------------------------------------------"

# DELETE FILES
echo ""
echo "----------------------------------------------------------"
echo " Delete the files from server."
echo "----------------------------------------------------------"
duck --username $FTP_USER --password $FTP_PASSWORD --delete $FTP_SERVER/$FTP_RELEASE_DIR/$RELEASE_FILE
echo " The release file $RELEASE_FILE was deleted."
duck --username $FTP_USER --password $FTP_PASSWORD --delete $FTP_SERVER/$FTP_RELEASE_DIR/$SCRIPT_FILE
echo " The instalation script $RELEASE_DIR/$SCRIPT_FILE was deleted."
echo "----------------------------------------------------------"

# INFO
echo ""
echo "----------------------------------------------------------"
echo " The instalation status"
echo "------------------------------------------"
echo " Current version: $(curl -s http://www.ajka-andrej.com/$VERSION_FILE)"
echo " Current release date: $(curl -s http://www.ajka-andrej.com/$RELEASE_DATE_FILE)"
echo " Instalation status: $SCRIPT_STATUS"
echo "------------------------------------------"
