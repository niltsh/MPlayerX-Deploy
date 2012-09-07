
PWD=`pwd`

if [[ $# != 1 ]]; then
	echo "./upload-googlecode.sh [版本编号]"
	exit
fi

BIN=$PWD/releases/MPlayerX-$1.zip

if [[ -f $BIN ]]; then
    GCUSER=support@mplayerx.org
	GCPSWD=`security find-generic-password -w -s "MPlayerX-GoogleCode"`

	./scripts/googlecode_upload.py -p mplayerx -s $1 -u $GCUSER -w $GCPSWD $BIN

	md5 $BIN
else
	echo "$BIN does not exists."
fi
