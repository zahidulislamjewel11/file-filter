#!/usr/bin/bash

# resetting
`find . -type d -iname output -exec rm -Rf {} +`
`find . -type f -name report.txt -exec rm -Rf {} +`
`find . -type f -name report.csv -exec rm -Rf {} +`

# function for filtering files
file_filter() {
    
    working_directory=$1
    input_file=$2
    ignoreFileList=`cat $input_file`
    fileList=`find $working_directory -type f -iname "*.*"`

    # step-1: grouping files by their extensions
    for file in $fileList 
    do
        filename="${file##*/}" # trimming the longest match of */ from start position
        dir="${file%/*}" # trimming the longest match of /* from end position
        ext="${file##*.}"                  # Substring from len of base thru end

        `mkdir -p output/$ext`
        `cp -n $file output/$ext`  # -n, --no-clobber
        `echo $file | cat >> output/$ext/dirList.txt`
        # do NOT overwrite an existing file (overrides a previous -i option)	
    done

    # step-1.5: managing others
    otherFileList=`find $working_directory -type f ! -name "*.*"`
    `mkdir -p output/others`
    for file in $otherFileList 
    do 
        `cp -n $file output/others`  # -n, --no-clobber
        printf "others\n" >> report.txt
    done

    # step-2: deleting files according to input/ignore file
    for x in $ignoreFileList
    do
        x=$(echo $x | rev | cut -c2- | rev)  
        # x=$(echo $x | sed 's/.$//')  
        # x=$(echo $x | awk '{print substr($0, 1, length($0)-1)}')  
        # `rm -rf output/$temp`
        `find output -type d -name $x -exec rm -rf {} +`
    done

    # step-3: writing csv report
    `touch report.txt`
    `touch report.csv`

    fileList=`find output -type f -iname "*.*"`
    for file in $fileList 
    do 
        ext="${file##*.}"   
        # `echo $ext | >> report.txt`
        printf "$ext\n" >> report.txt
    done

    $(cat report.txt | sort | uniq -c | awk '{print $2 "," $1}' > report.csv)
    # clear
}


# clear
if [[ $# -eq 0 ]]; then
    echo "invalid input"
    echo "enter in the following format"
    echo "<script> <directory(optional)> <file(needed)>"


elif [[ $# -eq 1 ]]; then
    file=$1
    directory="."
    echo "# input file: $file"
    echo "# working directory: $directory"
    
    file_filter $directory $file

elif [[ $# -eq 2 ]]; then
    directory=$1
    file=$2
    echo "# input file: $file"
    echo "# working directory: $directory"

    file_filter $directory $file
fi
