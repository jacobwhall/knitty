set tagname=0.3.4
git tag -d %tagname%
git push --delete origin %tagname%
git tag -a %tagname%
git push --tags
pause
