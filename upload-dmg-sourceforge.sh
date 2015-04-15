
PWD=`pwd`

if [[ $# != 1 ]]; then
	echo "./upload-sourceforge.sh [版本编号]"
	exit
fi

BIN=$PWD/releases/MPlayerX-$1.dmg

if [[ -f $BIN ]]; then
    SFUSER=quzongyao
    SFPROJ=mplayerx-osx

    scp ${BIN} ${SFUSER}@frs.sourceforge.net:/home/frs/project/${SFPROJ}

	md5 $BIN
else
	echo "$BIN does not exists."
fi
