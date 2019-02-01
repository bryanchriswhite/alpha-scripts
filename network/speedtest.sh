#!/bin/bash

calc() { awk "BEGIN{print $*}"; }

function speedtest {
	testcase=$1
	filesize=$2
	s3options=$3
	awsid=$4
	awskey=$5
	
	if [ -z $awsid -o -z $awskey ] ; then
		results[${#results[@]}]=$(echo "")
		results[${#results[@]}]=$(echo "aws_access_key_id or aws_secret_access_key missing for $testcase")
		return
	fi
	echo
	echo "executing $testcase speedtest"

	#Configurate AWS
	aws configure set default.aws_access_key_id $awsid
	aws configure set default.aws_secret_access_key $awskey
	aws configure set default.region us-east-1
	aws configure set default.s3.multipart_threshold 1TB
	
	localfile=/tmp/storjspeedtest
	
	#change filesize here
	head -c $filesize </dev/urandom > $localfile
	filesize=$(du -b $localfile | cut -f1)
	
	#file hash for unique filenames
	checksum=$(sha512sum $localfile | cut -d ' ' -f1)
	bucket="speedtest${checksum:0:50}"
	remotefile=s3://$bucket/randomdata
	
	#create bucket just in case it doesn't exists
	aws s3 $s3options mb s3://$bucket
	
	#speed test upload
	echo
	echo "start uploadtest"
	before=$(date +%s%N)
	aws s3 $s3options cp $localfile $remotefile
	after=$(date +%s%N)
	uploadtime=$(calc $(calc $after - $before) / 1000000000)
	echo "end uploadtest"
	
	#speed test download
	echo
	echo "start downloadtest"
	before=$(date +%s%N)
	aws s3 $s3options cp $remotefile /tmp/$checksum
	after=$(date +%s%N)
	downloadtime=$(calc $(calc $after - $before) / 1000000000)
	echo "end downloadtest"
	
	#verify checksum
	echo
	if [ $(sha512sum /tmp/$checksum | cut -d ' ' -f1) == $checksum ] ; then
		echo "verify checksum successfully"
		
		#cleanup
		echo
		echo "delete local and remote testfile"
		aws s3 $s3options rm $remotefile
		aws s3 $s3options rb s3://$bucket
		rm $localfile
		rm /tmp/$checksum
		
		#print out test results
		results[${#results[@]}]=$(echo "")
		results[${#results[@]}]=$(echo "$testcase test results")
		results[${#results[@]}]=$(echo "filesize:" $(calc $filesize / 1024) "KBytes")
		results[${#results[@]}]=$(echo "upload speed:" $(calc $filesize / $uploadtime / 1024) "KBytes/s ($uploadtime seconds)")
		results[${#results[@]}]=$(echo "download speed:" $(calc $filesize / $downloadtime / 1024) "KBytes/s ($downloadtime seconds)")
	else
		results[${#results[@]}]=$(echo "")
		results[${#results[@]}]=$(echo "$testcase verify checksum failed")
		results[${#results[@]}]=$(echo "please check the downloaded file /tmp/$checksum against the uploaded file $localfile and remote file $remotefile")
	fi
}

results=()

filesize=4M

# Storj speedtest
speedtest "Storj" $filesize "--endpoint=http://127.0.0.1:7777" "insecure-dev-access-key" "insecure-dev-secret-key"

# Amazon AWS speedtest
aws_access_key_id=""
aws_secret_access_key=""
speedtest "Amazon AWS" $filesize "" $aws_access_key_id $aws_secret_access_key

# Print out all test results
for i in ${!results[@]}; do
	echo ${results[$i]}
done