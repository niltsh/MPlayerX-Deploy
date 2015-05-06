
if [[ $# -lt 1 ]]; then
	echo "./upload-sourceforge.sh <文件路径> [服务器端子文件夹名称]"
	exit
fi

BIN=${1}

if [[ -f $BIN ]]; then
    SFUSER=quzongyao
    SFPROJ=mplayerx-osx

	if [[ $2 ]]; then
		echo "scp ${BIN} ${SFUSER}@frs.sourceforge.net:/home/frs/project/${SFPROJ}/$2"
		scp ${BIN} ${SFUSER}@frs.sourceforge.net:/home/frs/project/${SFPROJ}/$2
	else
	    echo "scp ${BIN} ${SFUSER}@frs.sourceforge.net:/home/frs/project/${SFPROJ}"
		scp ${BIN} ${SFUSER}@frs.sourceforge.net:/home/frs/project/${SFPROJ}
	fi

	md5 $BIN
else
	echo "$BIN does not exists."
fi
