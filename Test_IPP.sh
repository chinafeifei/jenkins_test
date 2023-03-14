#!/bin/bash

set -e

#WORKDIR=$(find ~  -name 'applications.industrial.machine-vision.computer-vision-optimization-toolkit-pv_rc1' | head -n 1)
WORKDIR=$(pwd)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/intel/oneapi/ipp/latest/lib/intel64/tl/tbb
source /opt/intel/oneapi/setvars.sh
source /opt/intel/openvino_2021.4.752/bin/setupvars.sh
File_run=$HOME/run_reult.txt
#File_result=$HOME/"$(date +%H%M%S)"_result.txt

# Run Sobel Sample
cd $WORKDIR/SobelGradient
mkdir build
cd build
cmake ..
make VERBOSE=1
k=14
j=6
sum_ipp=0
sum_cv=0

make run-hypot >> $File_run
loc_str1="$j"p""
loc_str2="$k"p""
str=`sed -n $loc_str1 $File_run`
array_opencv=($str)
max_cv=${array_opencv[4]}
min_cv=${array_opencv[4]}
str2=`sed -n $loc_str2 $File_run`
array_ipp=($str2)
max_ipp=${array_ipp[6]}
min_ipp=${array_ipp[6]}


for ((i=0; i<10; i++));
do
	make run-hypot >> $File_run
	loc_str1="$j"p""
        loc_str2="$k"p""
	
	str=`sed -n $loc_str1 $File_run`
	array_opencv=($str)
	if ((${array_opencv[4]} > $max_cv))
	then
		max_cv=${array_opencv[4]}
	elif ((${array_opencv[4]} < $min_cv))
	then
		min_cv=${array_opencv[4]}	
	fi

	sum_cv=`expr $sum_cv + ${array_opencv[4]}`

	str2=`sed -n $loc_str2 $File_run`
	array_ipp=($str2)
	if ((${array_ipp[6]} > $max_ipp))
        then
                max_ipp=${array_ipp[6]}
	elif ((${array_ipp[6]} < $min_ipp))
	then
                min_ipp=${array_ipp[6]}
        fi

	sum_ipp=`expr $sum_ipp + ${array_ipp[6]}`

        j=`expr $j + 20`
	k=`expr $k + 20`
done

printf "%-12s %-10s %-10s %-10s %-10s %-10s %-10s\n" Filter OpenCV_Min OpenCV_Ave OpenCV_Max CVOI_Min CVOI_Ave CVOI_Max 
printf "%-12s %-10.2f %-10.2f %-10.2f %-10.2f %-10.2f %-10.2f\n" Sobel_hypot $min_cv `expr $sum_cv / 10` $max_cv $min_ipp `expr $sum_ipp / 10` $max_ipp 

rm $File_run
cd ..
rm -r build
