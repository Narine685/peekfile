# determining the number of lines to use with head and tail commands
if [[ -n $2 ]]; # with this condition, if a second argument is given... 
then
  lines=$2 #...then that number of lines will be used for the commands...
else
  lines=0 #...otherwise, 0 will be taken as a default
fi


#obtaining the paths of the files
echo -e "Obtaining the paths of the files\n\n" # echo to inform the user in which step the script is
paths=$(find $1 -type "f" -name "*.fa" -or -type "f" -name "*.fasta" -or -type "l" -name "*.fa" -or -type "l" -name "*.fasta" ) # the files obtained will be saved in a variable for later use


#calculating the number of .fasta/.fa files
echo -e "Calculating the number of files obtained:\nThere are $(echo "$paths" | wc -l) fasta/fa files in $1 folder or subfolders\n\n" # inform the user of the number of files found


#calculating the number of unique IDs in total 
echo -e "Calculating the number of unique IDs in the totality of fasta and fa files found:" # echo to indicate the step in which the script is
for path in $paths # this loop will be used to save ALL the IDs (first words of the entries heads) in a file 
    do if [[ $(grep ">" $path|wc -l) -gt 0 ]] #this step is used to make sure that the files used are text, not binary
        then 
            grep ">" $path | awk '{print $1}' >> IDs
    fi
done
echo "There are $(sort IDs |uniq -c | wc -l) unique IDs in the totality of fasta and fa files in $1" # print the number of unique IDs in the file with ALL IDs

#obtaining a summary of each file
for path in $paths
    do if [[ $(grep ">" $path|wc -l) -gt 0 ]]
    then
        echo -e "\n\n=== $path ===" # print which file we are giving information about
        if [[ -h $path ]] # with this condition, the user will get the information whether the file is a symbolic link or not 
        then 
            echo "This file is a symlink."
        else
            echo "This file is not a symlink."
        fi
        echo "There are $(grep -c ">" $path) sequences inside." # obtaining the number of sequences inside the file
        total_residus=$(awk '!/>/ && length($0)> 0{gsub(/[-"\n"" "]/, "", $0)} !/>/ && length($0)> 0{len+=length($0)}END{print len}' $path) # here we modify the lines that don't start with > (sequence lines) so that the lines don't have gaps, spaces or new line characters, then, with the modified lines, a variable called len will store the added value of each sequence line, obtaining this way the total number of nucleotide or aminoacid residus of teh file, and this number will be stores in the variable total_residus.
        if [[ $(cat $path | grep -v ">" | grep -i -c [RNDQEHILKMFPSWYV]) >0 ]] # if we find symbols that pertain to aminoacids...
        then
            type=aminoacids # ... then we classify the type of the file as containing aminoacids...
        else
            type=nucleotides #... and if not, we classify it as containing nucleotides
        fi
        echo "This file contains sequences of $type, and there are in total $total_residus $type between all sequences" # the results of both the type of file and the total lenght of the sequences is reported
        if [[ $lines -eq 0 ]] # if the default number of lines is being used, no content of the file will be shown 
        then
            continue
        elif [[ $(cat $path | wc -l) -le $(( $lines * 2 )) ]] #if teh number of lines of the file is lower than two times the number of lines wanted, the whole file will be printed
        then
            cat $path
        else #if it is more than two times the number of lines wanted, a head and a tail commands will be used 
            head -n $lines $path
            echo ...
            tail -n $lines $path
        fi
    fi
done 
