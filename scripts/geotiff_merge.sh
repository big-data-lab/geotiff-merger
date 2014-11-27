#!/bin/bash

base=`dirname $0`
tmp_dir=/tmp/geotiff_merge/

target_dir=$2
sub_dir=`basename $1`
dest_dir=$2/$sub_dir
tmp_tiff_dir=$tmp_dir/$sub_dir/tiffs/
tmp_merged_file=$tmp_dir/$sub_dir/out.tiff

mkdir -p `dirname $tmp_merged_file`

mkdir -p $dest_dir

mkdir -p $tmp_tiff_dir

# make sure there is no left out
\rm -rf $tmp_tiff_dir/*

>&2 echo "$dest_dir"

function merge_on_dir {

	image_types=`$base/find_uniq_image_types.sh $1`;
	locations=`$base/find_uniq_locations.sh $1`;
	
	for type in $image_types
	do 
		>&2 echo "searching image type $type";
		
		for location in $locations
		do
			>&2 echo "location: $location";
			
			find $1 -name "${type}_${location}*" -type f | awk -F "\/" '{print $NF}' | awk -F "-" '{print $1 "-" $2 "-" $3 "-" $4}' | while read line; 
			do 
				line_len=${#line}; 
				want_len=`expr $line_len - 3`; 
				echo ${line:0:`echo $want_len`}; 
				done | sort | uniq -d | while read suffix				
				do
					>&2 echo "merging file $suffix"
					
					tmp_merged_file=$tmp_dir/${suffix}.tif
					for file in `find $1 -name "${suffix}*"`
					do
						name=`basename $file`
						name_len=${#name};
						want_name_len=`expr $name_len - 3`; 
						#name=`basename $file | awk -F "." '{print $1 "." $2 "." $3}'``
						name=${name:0:`echo $want_name_len`}
						zcat $file > $tmp_tiff_dir/$name
					done
					gdal_merge.py -o $tmp_merged_file -n -999 $tmp_tiff_dir/*
					\rm -rf $tmp_tiff_dir/*
					gzip -c $tmp_merged_file > $dest_dir/${suffix}.tif.gz
					\rm -rf $tmp_merged_file
				done
		done
	done
}

#if [ -d ..$1 ]; 
#then
#	for dir in `ls`
#	do
		merge_on_dir $1
#	done
	
	