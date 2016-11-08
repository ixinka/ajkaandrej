#!/bin/bash

echo "starting hugo server..."
hugo server --theme=hugo-icarus-theme --i18n-warnings --buildDrafts --watch
