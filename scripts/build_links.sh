#!/bin/bash

if ! [ $# -eq "3" ]; then
	>&2 echo "Erro, incorrect pramaters $#"
	echo "Usage: $0 source_image_dir merged_image_dir link_dir"
	exit
fi  

source_dir=`readlink -m $1`
target_dir=$2
links_dir=$3

sub_dir=`basename $1`
mkdir -p $links_dir/$sub_dir

ls $1 | awk -F "\/" '{print $NF}' | while read file; 
do 
	line=`echo $file | awk -F "-" '{print $1 "-" $2 "-" $3 "-" $4}'`
	line_len=${#line}; 
	want_len=`expr $line_len - 3`; 
	suffix=${line:0:`echo $want_len`}; 
	
	ls $target_dir/${suffix}* 2>/dev/null 1>/dev/null
	
	if ! [ $? -eq "0" ]; then
		>&2 echo "merging $suffix is not required"
		ln -s $source_dir/$file $links_dir/$sub_dir/$file 
	else
		ln -s $target_dir/${suffix}.tif.gz  $links_dir/$sub_dir/${suffix}T00-00-00.000000.tif.gz
	fi
done