#!/bin/bash


if [[ $# != 1 ]]; then
	echo "./update.sh [app文件路径名]"
	exit
fi

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH

RLSAPP=${1%/}
KEYTEMP="key.txt"
PRIVKEY="key2.txt"

CURDIR="$PWD"
appName=`basename "$RLSAPP"`

if [[ -d "$RLSAPP" ]]; then

	spctlRes=`spctl --verbose=4 --assess --type execute "$RLSAPP" 2>&1`
	spctlPass=`echo ${spctlRes} | grep ": accepted"`
	if [[ -n ${spctlPass} ]]; then
		echo "Passed spctl"
	else
		echo "spctl verification failed"
		exit 1
	fi

	# 得到版本信息
	shortVer=`/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby scripts/getShortVersionString.rb "$RLSAPP"`
	echo "ShortVersionString:      " $shortVer

	verNum=`/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby scripts/getVersion.rb "$RLSAPP"`
	echo "VersionNumber:           " $verNum

	mpxMin=`/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby scripts/getMPXMinVersion.rb "$RLSAPP"`
	echo "MPXMinVersion:           " $mpxMin

	# 获取 压缩文件文件名
	DEPLOYBIN="${CURDIR}/releases/${appName%.*}-$shortVer.zip"

    # 如果之前有拷贝就先删除
	rm -Rf $DEPLOYBIN

	# 压缩APP文件
    cd "$RLSAPP/.."
    zip -ry "$DEPLOYBIN" "$appName" > /dev/null
    cd "${CURDIR}"

	# 获取压缩文件尺寸
	fileSize=`stat -f %z "$DEPLOYBIN"`
	echo "FileSize:                " $fileSize

	# 获取压缩文件修改时间
	binTime=`stat -f %Sm -t "%a, %d %b %Y %H:%M:%S" "$DEPLOYBIN"`" +0900"
	echo "BinTime:                 " $binTime
	releaseDate=`stat -f %Sm -t "%Y/%m/%d" "$DEPLOYBIN"`

	# 获取压缩文件 签名
	security find-generic-password -g -s "MPlayerX Private Key" 1>/dev/null 2>$KEYTEMP
	ruby scripts/parsePriKey.rb $KEYTEMP > $PRIVKEY
	rm -Rf $KEYTEMP

	signature=`openssl dgst -sha1 -binary $DEPLOYBIN | openssl dgst -dss1 -sign $PRIVKEY | openssl enc -base64`
	rm -Rf $PRIVKEY
	echo "Signature:               " $signature

	cat appcast-template.xml | sed -e "s|%ReleaseDate%|${releaseDate}|g" | sed -e "s|%VerStr%|${shortVer}|g" | sed -e "s|%VerNum%|${verNum}|g" | sed -e "s|%Time%|${binTime}|g" | sed -e "s|%FileSize%|${fileSize}|g" | sed -e "s|%Signature%|${signature}|g" > appcast.xml
else
	echo "没有找到二进制文件，请确认。"
fi