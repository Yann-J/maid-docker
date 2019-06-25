#/bin/sh

# Perform a software update, if requested
# Courtesy of https://github.com/jakbutler/docker-calibredb/blob/master/run_auto_importer.sh
install=0
if [ -x ${CALIBRE_HOME}calibre/calibre ]; then
  my_version=$(${CALIBRE_HOME}calibre/calibre --version | awk -F'[() ]' '{print $4}')
  echo "Detected version $my_version, checking for latest..."
  latest_version=$(curl -sS "https://raw.githubusercontent.com/kovidgoyal/calibre/master/Changelog.yaml" | grep -m 1 "^- version:" | awk '{print $3}')
  if [ "$my_version" != "$latest_version" ]
  then
    echo "Updating from $my_version to $latest_version."
    install=1
  else
    echo "Installed version of $my_version is the latest."
  fi
else
  # No install present, proceed
  echo "Calibre not installed, proceed"
  install=1
fi

if [ "$install"=="1" ]; then
  wget -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main(install_dir='$CALIBRE_HOME', isolated=True)"
  # override pdftools from poppler
  cp -f /usr/bin/pdfinfo   $CALIBRE_HOME/calibre/bin/
  cp -f /usr/bin/pdftohtml $CALIBRE_HOME/calibre/bin/
  cp -f /usr/bin/pdftoppm  $CALIBRE_HOME/calibre/bin/
  # Cleanup
  rm -rf /tmp/calibre-installer-cache
fi
