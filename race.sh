#!/bin/bash

CYAN='\033[1;36m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m'
PACE_MODE="pace"
TIME_MODE="time"
CALC_MODE="calc"

mode=$PACE_MODE
quiet=0

usage() {
  printf "  race ${YELLOW}[OPTIONS]${NC} distance [times]\n\n"
  printf "  ${CYAN}Arguments${NC}\n"
  printf "\tdistance\trequired for pace and time modes\n"
  printf "\ttimes\t\ttime or pace, provided in HH:MM:SS format. HH is optional\n"
  printf "\t\t\tif only one number is provided, it is considered to be seconds\n"
  printf "\n"
  printf "  ${CYAN}Options${NC}\n"
  printf "\t-p (default) calculate the required average pace to run a distance at the specified time\n"
  printf "\t-t calculate the resulting time running a distance at the specified pace\n"
  printf "\t-c takes two times and adds them together\n"
  printf "\t-s no color output\n"
  printf "\t-q quiet output: only output the resulting calculation\n"
  printf "  ${CYAN}Examples${NC}\n"
  printf "    race 10 40:00\t# will calculate the average pace to run 10km in 40 minutes\n"
  printf "    >>> Average Pace: ${GREEN}4:00${NC}\n"
  printf "    race 10 -t 4:00\t# will calculate the final time for 10 km at 4:00/km\n"
  printf "    >>> Final Time: ${GREEN}40:00${NC}\n"
  printf "    race -c 40:45 5:25\t# will add the two times together\n"
  printf "    >>> 46:10\n"
}

zeroPad() {
  if [ $1 -lt 10 ]; then
    echo "0${1}"
  else
    echo $1
  fi
}

formatTime() {
  secsArg=$1
  hours=0
  
  secs=$((secsArg % 60))
  minutes=$((secsArg / 60))

  if [ $minutes -gt 60 ]; then
    hours=$((minutes / 60))
    minutes=$((minutes % 60))
  fi

  time=''
  if [ $hours -gt 0 ]; then
    time="$hours:"
  fi
  time+="$(zeroPad $minutes):$(zeroPad $secs)"
  echo "$time"
}

getSecondsFromTime() {
  IFS=':' read -ra timeParts <<< "$1"
  unset IFS
  len=${#timeParts[@]}
  power=1
  secs=0
  for ((i=len-1; i >= 0; i--));
  do
    secs=$((${timeParts[$i]} * power + secs))
    power=$((power * 60))
  done
  echo $secs
}

# parse out our options
while getopts "hptcsq" opt; do
  case "${opt}" in
    h)
      usage
      exit 0
      ;;
    p)
      mode=$PACE_MODE
      ;;
    t)
      mode=$TIME_MODE
      ;;
    c)
      mode=$CALC_MODE
      ;;
    s)
      CYAN=''
      YELLOW=''
      GREEN=''
      NC=''
      ;;
    q)
      quiet=1
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

# get arguments
shift $((OPTIND - 1))
if [ $mode != $CALC_MODE ]; then
  distance=$1
  shift 1
fi
secs=$(getSecondsFromTime $1)

if [ $mode = $PACE_MODE ]; then
  paceTotal=$((secs/distance))
  if [ $quiet -eq 0 ]; then
    printf "Average Pace: ${GREEN}$(formatTime $paceTotal)${NC} per km\n"
  else
    printf "${GREEN}$(formatTime $paceTotal)${NC}\n"
  fi
fi

if [ $mode = $TIME_MODE ]; then
  targetSeconds=$((secs*distance))
  if [ $quiet -eq 0 ]; then
    printf "Final Time: ${GREEN}$(formatTime $targetSeconds)${NC}\n"
  else
    printf "${GREEN}$(formatTime $targetSeconds)${NC}\n"
  fi
fi

if [ $mode = $CALC_MODE ]; then
  b_secs=$(getSecondsFromTime $2)
  t_secs=$((secs + b_secs))
  printf "$(formatTime $t_secs)\n"
fi