# determining the number of lines to use with head and tail commands
if [[ -n $2 ]]; # with this condition, if a second argument is given... 
then
  lines=$2 #...then that number of lines will be used for the commands...
else
  lines=3 #...otherwise, 0 will be taken as a default
fi

#obtaining the paths of the files
echo -e "Obtaining the paths of the files\n\n" # echo to inform the user in which step the script is
paths=$(find $1 -type "f" -name "*.fa" -or -type "f" -name "*.fasta") #obtaining all .fasta and .fa files in the folder and subfolders and saving their paths for later use

#calculating the number of .fasta/.fa files
echo -e "Calculating the number of files obtained:\nThere are $(echo "$paths" | wc -l) fasta/fa files in $1 folder or subfolders\n\n" #this line of code serves for both idnicating the step in which the script is and to calculate the number of .fasta and .fa files in the $paths variable

#calculating the number of unique IDs in total 
echo -e "Calculating the number of unique IDs in the totality of fasta and fa files found:" # echo to indicate the step in which the script is
for path in $paths # 
    do if [[ $(grep ">" $path|wc -l) -gt 0 ]]
        then grep ">" $path | awk '{print $1}' >> IDs
    fi
done
echo "There are $(sort IDs |uniq -c | wc -l) unique IDs in the totality of fasta and fa files in $1\n"



