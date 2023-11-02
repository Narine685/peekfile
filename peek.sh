if [[ -n $2 ]];
then
  lines=$2
else
  lines=3
fi

if [[ $(cat $1 | wc -l) -le $(( $lines * 2 )) ]]
then
  cat $1
else
  echo "Warning: the file passed has more lines than two times the lines specified or the default lines (3), not all lines will be printed"
  head -n $lines $1
  echo ...
  tail -n $lines $1
fi
