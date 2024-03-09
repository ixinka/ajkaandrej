# Install
sudo apt-get install jhead
cp thumbnail ~/bin/.
chmod +x ~/bin/thumbnail

# Start server

```
hugo server --ignoreCache --buildDrafts --watch
```

Check the translations
```
hugo --printI18nWarnings | grep i18n
```

# Git

Status
```
git status -s
```

Update
```
git pull
```

Add changes

```
git add .
git commit -m "Update message"
git push
```
