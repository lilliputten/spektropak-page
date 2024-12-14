#!/bin/sh
# @desc Update version number & build timestamps
# @changed 2024.12.14, 18:09

scriptsPath=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")
rootPath=`dirname "$scriptsPath"`
prjPath="$rootPath" # `pwd`

# Import config variables...
test -f "$scriptsPath/config.sh" && . "$scriptsPath/config.sh"
test -f "$scriptsPath/config-local.sh" && . "$scriptsPath/config-local.sh"

# # Check basic required variables...
# test -f "$rootPath/config-check.sh" && . "$rootPath/config-check.sh"

# Read (and derive) variables from changed files...
VERSION_PATH="$rootPath/${VERSION_FILE}"
VERSION=`cat "$VERSION_PATH"`
TIMESTAMP=`date -r "$VERSION_PATH" "+%Y.%m.%d %H:%M:%S %z"`
TIMETAG=`date -r "$VERSION_PATH" "+%y%m%d-%H%M"`

PROJECT_HASH="v.$VERSION-$TIMETAG"
PROJECT_INFO="v.$VERSION / $TIMESTAMP"
PROJECT_INFO_REP=`echo "$PROJECT_INFO" | sed 's,/,\\\\/,g'` # Quoted for replace, see below

echo "Version/time: $PROJECT_INFO"

if [ ! -z "${PROJECT_HASH_FILE}" ]; then
  echo "Creating '$PROJECT_HASH_FILE' file..."
  echo "$PROJECT_HASH" > $rootPath/$PROJECT_HASH_FILE
fi

if [ ! -z "${PROJECT_INFO_FILE}" ]; then
  echo "Creating '$PROJECT_INFO_FILE' file..."
  echo "$PROJECT_INFO" > $rootPath/$PROJECT_INFO_FILE
fi

if [ ! -z "${PROJECT_INFO_SCSS_FILE}" ]; then
  echo "Creating '$PROJECT_INFO_SCSS_FILE' file..."
  echo ":root { --PROJECT-INFO:" > $rootPath/$PROJECT_INFO_SCSS_FILE
  echo "  $PROJECT_INFO" >> $rootPath/$PROJECT_INFO_SCSS_FILE
  echo "}" >> $rootPath/$PROJECT_INFO_SCSS_FILE
fi

if [ ! -z "${PROJECT_INFO_JSON_FILE}" ]; then
  echo "Creating '$PROJECT_INFO_JSON_FILE' file..."
  echo "{ \"projectInfo\": \"$PROJECT_INFO\" }" > $rootPath/$PROJECT_INFO_JSON_FILE
fi

UPDATE_FILE() {
  FILE=$1
  if [ ! -f $FILE ]; then
    # echo "File $FILE doesn't exists"
    return
  fi
  NAME="${FILE##*/}" # Exract extension
  EXT="${NAME##*.}" # Exract extension
  echo "Updating file $NAME ($FILE)..."
  mv $FILE $FILE.bak || exit 1
  # # TODO: Replace only first occurence of `version`
  if [ "$NAME" = "package-lock.json" ]; then # package-lock
    # NOTE: Update only first occurenece of verion parameter in package-lock...
    echo "package-lock.json"
    cat $FILE.bak \
      | sed "0,/\(\"version\":\) \".*\"/{s//\1 \"$VERSION\"/}" \
    > $FILE || exit 1
  elif [ "$EXT" = "json" ]; then # JSON
    cat $FILE.bak \
      | sed "s/\(\"version\":\) \".*\"/\1 \"$VERSION\"/" \
      | sed "s/\(\"timestamp\":\) \".*\"/\1 \"$TIMESTAMP\"/" \
      | sed "s/\(\"timetag\":\) \".*\"/\1 \"$TIMETAG\"/" \
    > $FILE || exit 1
  elif [ "$EXT" = "local" ]; then # env.local files
    cat $FILE.bak \
      | sed "s/\(version=\)\s*\".*\"/\1\"$VERSION\"/" \
      | sed "s/\(timestamp=\)\s*\".*\"/\1\"$TIMESTAMP\"/" \
      | sed "s/\(timetag=\)\s*\".*\"/\1\"$TIMETAG\"/" \
    > $FILE || exit 1
  elif [ "$EXT" = "toml" ]; then # Python
    cat $FILE.bak \
      | sed "s/\(version =\) \([\"']\).*\2/\1 \2$VERSION\2/" \
      | sed "s/\(timestamp =\) \([\"']\).*\2/\1 \2$TIMESTAMP\2/" \
      | sed "s/\(timetag =\) \([\"']\).*\2/\1 \2$TIMETAG\2/" \
    > $FILE || exit 1
  elif [ "$EXT" = "py" ]; then # Python
    cat $FILE.bak \
      | sed "s/\(__version__ =\) \([\"']\).*\2/\1 \2$VERSION\2/" \
      | sed "s/\(__timestamp__ =\) \([\"']\).*\2/\1 \2$TIMESTAMP\2/" \
      | sed "s/\(__timetag__ =\) \([\"']\).*\2/\1 \2$TIMETAG\2/" \
    > $FILE || exit 1
  elif [ "$EXT" = "html" ]; then # HTML: Replace data in meta tags
    cat $FILE.bak \
      | sed "s/\(project-info\" content=\)\([\"']\).*\2/\1 \2$PROJECT_INFO_REP\2/" \
      | sed "s/\(version\" content=\)\([\"']\).*\2/\1 \2$VERSION\2/" \
      | sed "s/\(timestamp\" content=\)\([\"']\).*\2/\1 \2$TIMESTAMP\2/" \
      | sed "s/\(timestag\" content=\)\([\"']\).*\2/\1 \2$TIMESTAG\2/" \
    > $FILE || exit 1
  else # MD, other free format files...
    cat $FILE.bak \
      | sed "s/\(Project info:\) .*$/\1 $PROJECT_INFO_REP/" \
      | sed "s/\(Version:\) .*$/\1 $VERSION/" \
      | sed "s/\(Last changes timestamp:\) .*$/\1 $TIMESTAMP/" \
      | sed "s/\(Last changes timetag:\) .*$/\1 $TIMETAG/" \
    > $FILE || exit 1
  fi
  rm $FILE.bak || exit 1
}

UPDATE_FILE "$prjPath/.env.local" # TODO: Use '.env*'
UPDATE_FILE "$prjPath/package.json"
UPDATE_FILE "$prjPath/pyproject.toml"
UPDATE_FILE "$prjPath/package-lock.json"
UPDATE_FILE "$prjPath/README.md"
UPDATE_FILE "$prjPath/public/index.html"
