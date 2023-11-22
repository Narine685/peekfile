# determining the folder and number of lines to use
if [[ -n $1 ]]; # with this condition, if a folder argument is given... 
then
  folder=$1 #...then that folder will be used for the commands...
else
  folder=. #...otherwise, the current one will be taken as a default
fi

if [[ -n $2 ]]; # with this condition, if a second argument is given... 
then
  lines=$2 #...then that number of lines will be used for the commands...
else
  lines=0 #...otherwise, 0 will be taken as a default
fi


#obtaining the paths of the files
echo -e "Obtaining the paths of the files\n\n" # echo to inform the user in which step the script is
paths=$(find $folder -type "f" -name "*.fa" -or -type "f" -name "*.fasta" -or -type "l" -name "*.fa" -or -type "l" -name "*.fasta" ) # the files obtained will be saved in a variable for later use


#calculating the number of .fasta/.fa files
echo -e "Calculating the number of files obtained:\nThere are $(echo "$paths" | wc -l) fasta/fa files in $folder folder or subfolders\n\n" # inform the user of the number of files found


#calculating the number of unique IDs in total 
echo -e "Calculating the number of unique IDs in the totality of fasta and fa files found:" # echo to indicate the step in which the script is
for path in $paths # this loop will be used to save ALL the IDs (first words of the entries heads) in a file 
    do if [[ $(grep ">" $path|wc -l) -gt 0 ]] #this step is used to make sure that the files used are text, not binary
        then 
            grep ">" $path | awk '{print $1}' >> IDs #IDs is the file
    fi
done
echo "There are $(sort IDs |uniq -c | wc -l) unique IDs in the totality of fasta and fa files in $1" # print the number of unique IDs in the file with ALL IDs

#obtaining a summary of each file
for path in $paths
    do if [[ $(grep ">" $path|wc -l) -gt 0 ]] # if the file is not binary
    then
        
        # print which file we are giving information about
        echo -e "\n\n=== $path ===" 
        
        #check if it is a symbolic link
        if [[ -h $path ]] 
        then 
            echo "This file is a symlink."
        else
            echo "This file is not a symlink."
        fi
        
        #obtaining the number of sequences inside the file
        echo "There are $(grep -c ">" $path) sequences inside." 
        
        #obtaining the total number of nucleotides or aminoacids, first the code eliminates gaps, spaces or new_line characters and then sums up the length of each sequence line 
        total_residus=$(awk '!/>/ && length($0)> 0{gsub(/[-"\n"" "]/, "", $0)} !/>/ && length($0)> 0{len+=length($0)}END{print len}' $path)
        
        #knowing if the sequences are made of aminoacids or nucleotides
        if [[ $(cat $path | grep -v ">" | grep -i -c [RNDQEHILKMFPSWYV]) >0 ]] # if we find symbols that pertain to aminoacids...
        then
            type=aminoacids # ... then we classify the type of the file as containing aminoacids...
        else
            type=nucleotides #... and if not, we classify it as containing nucleotides
        fi
        
        #echo the results of teh last two steps
        echo "This file contains sequences of $type, and there are in total $total_residus $type between all sequences" 
        
        #echo the portion of the file asked by the $lines variable
        if [[ $lines -eq 0 ]] 
        then
            continue
        elif [[ $(cat $path | wc -l) -le $(( $lines * 2 )) ]] 
        then
            cat $path
        else  
            head -n $lines $path
            echo ...
            tail -n $lines $path
        fi
    else #echo that this file is binary
    	echo -e "\n\n=== $path ===\nThe file $path is binary and therefore can not be processed with this code"
    fi
done 
