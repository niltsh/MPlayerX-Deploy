#!/bin/sh


if [[ $# != 1 ]]; then
	echo "./update.sh [app文件路径名]"
	exit
fi

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH

RLSBIN=$1
RLSAPP="./MPlayerX.app"
KEYTEMP="key.txt"
PRIVKEY="key2.txt"

if [[ -d $RLSBIN ]]; then

	# 删除临时存储的MPlayerX.app文件
	rm -Rf $RLSAPP
	# 将 编译好的app文件 拷贝到当前文件夹
	cp -R $RLSBIN $RLSAPP

	# 得到版本信息
	shortVer=`ruby scripts/getShortVersionString.rb $RLSAPP`
	echo "ShortVersionString:\t" $shortVer

	verNum=`ruby scripts/getVersion.rb $RLSAPP`
	echo "VersionNumber:\t\t" $verNum

	# 获取 压缩文件文件名
	DEPLOYBIN="./releases/MPlayerX-$shortVer.zip"
	
	# 如果之前有拷贝就先删除
	rm -Rf $DEPLOYBIN

	# 压缩APP文件
	zip -ry $DEPLOYBIN $RLSAPP > /dev/null

	# 获取压缩文件尺寸
	fileSize=`stat -f %z $DEPLOYBIN`
	echo "FileSize:\t\t" $fileSize

	# 获取压缩文件修改时间
	binTime=`stat -f %Sm -t "%a, %d %b %Y %H:%M:%S" $DEPLOYBIN`" +0900"
	echo "BinTime:\t\t" $binTime

	# 获取压缩文件 签名
	security find-generic-password -g -s "MPlayerX Private Key" 1>/dev/null 2>$KEYTEMP
	ruby scripts/parsePriKey.rb $KEYTEMP > $PRIVKEY
	rm -Rf $KEYTEMP

	signature=`openssl dgst -sha1 -binary $DEPLOYBIN | openssl dgst -dss1 -sign $PRIVKEY | openssl enc -base64`
	rm -Rf $PRIVKEY
	echo "Signature:" $signature

	cat appcast-template.xml | sed -e "s|%VerStr%|${shortVer}|g" | sed -e "s|%VerNum%|${verNum}|g" | sed -e "s|%Time%|${binTime}|g" | sed -e "s|%FileSize%|${fileSize}|g" | sed -e "s|%Signature%|${signature}|g" > appcast.xml

	rm -Rf $RLSAPP
	rm -Rf $RLSBIN
else
	echo "没有找到二进制文件，请确认。"
fi