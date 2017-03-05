#!/bin/bash

echo " Create public directory "
rm -rf public
hugo --theme=hugo-icarus-theme --i18n-warnings --ignoreCache
