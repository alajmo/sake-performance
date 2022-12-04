#!/bin/bash

set -e

NUM_HOSTS=(
  1
  3
  5
  8
  10
  25
  50
  100
  200
  300
  400
  500
)

function parse_options() {
  SOFTWARE=
  REPEAT=10
  while getopts 's:r:h' opt; do
    case "$opt" in
      s)
        SOFTWARE="$OPTARG"
        ;;
      r)
        REPEAT="$OPTARG"
        ;;
      ?|h)
        echo "Usage: $(basename $0) [-s SOFTWARE] [-r REPEAT]"
        exit 1
        ;;
    esac
  done
  shift "$(($OPTIND -1))"
}

function run_sake() {
  local _num_hosts="$1"
  local _cmd="$2"

  stats_str=$({ command time -f '%e %M %P' sake run "$_cmd" SAKE_NUM_HOSTS="$_num_hosts"; } 2>&1 1>/dev/null)

  echo $stats_str
}

function run_pyinfra() {
  local _num_hosts="$1"
  local _deploy="$2"

  export PYINFRA_TEST_HOSTS="$_num_hosts"
  /usr/bin/time -o out.time -f '%e %M %P' pyinfra inventory.py "$_deploy" --parallel=20 --quiet 2> /dev/null
  unset PYINFRA_TEST_HOSTS

  stats_str=$(cat out.time)
  rm out.time
  echo $stats_str
}

function run_ansible() {
  local _num_hosts="$1"
  local _playbook="$2"

  export ANSIBLE_TEST_HOSTS="$_num_hosts"
  stats_str=$({ command time -f '%e %M %P' ansible-playbook "$_playbook" -i inventory.py -c ssh --limit "all[0:$_num_hosts]" ; } 2>&1 1>/dev/null)
  unset ANSIBLE_TEST_HOSTS

  echo $stats_str
}

function benchmark() {
  local _test_case="$1"
  local _software="$2"
  local _cmd="$3"
  local _cmd_type="$4"

  echo "=== Starting $_software ==="
  cd $_software

  echo "name,time,cpu,mem" > "../results/$_test_case/csv/$_software.csv"
  for num_hosts in "${NUM_HOSTS[@]}"; do
    times=()
    mems=()
    cpus=()
    for j in $(seq 1 $REPEAT); do
      # %e Elapsed real (wall clock) time used by the process, in seconds
      # %M Maximum resident set size of the process during its lifetime, in Kilobytes
      # %P Percentage of the CPU that this job got
      stats_str=$($_cmd $num_hosts $_cmd_type)

      # Remove percentage sign from CPU
      stats_str=${stats_str%\%}

      read -a stats <<< "$stats_str"

      times+=(${stats[0]})
      mems+=(${stats[1]})
      cpus+=(${stats[2]})
    done

    time_s=$(echo ${times[@]} | datamash -t " " transpose | datamash --round=3 mean 1)
    mem=$(echo ${mems[@]} | datamash -t " " transpose | datamash --round=1 mean 1)
    mem="$mem""K"

    mem=$(numfmt --from=iec --to-unit=1Mi --grouping "$mem")
    cpu=$(echo ${cpus[@]} | datamash -t " " transpose | datamash --round=1 mean 1)
    cpu=$(printf "%.0f" "$cpu")

    echo "$num_hosts,$time_s,$cpu,$mem" >> "../results/$_test_case/csv/$_software.csv"
  done

  cd ..
  echo "=== Finished $_software ==="
  echo
}

function create_tables() {
  TIME_FILE="./results/$1/csv/time.csv"
  CPU_FILE="./results/$1/csv/cpu.csv"
  MEM_FILE="./results/$1/csv/mem.csv"
  SAKE_FILE="./results/$1/csv/sake.csv"
  PYINFRA_FILE="./results/$1/csv/pyinfra.csv"
  ANSIBLE_FILE="./results/$1/csv/ansible.csv"

  # Generate comparison tables
  > "$TIME_FILE"
  echo "name,sake,pyinfra,ansible" > "$TIME_FILE"
  mlr --csv cut -f name "$SAKE_FILE" | sed 1d \
    | paste - <(mlr --csv cut -f time "$SAKE_FILE" | sed 1d) \
    | paste - <(mlr --csv cut -f time "$PYINFRA_FILE" | sed 1d) \
    | paste - <(mlr --csv cut -f time "$ANSIBLE_FILE" | sed 1d) \
    | sed 's/\t/,/g' >> "$TIME_FILE"

  echo "name,sake,pyinfra,ansible" > "$CPU_FILE"
  mlr --csv cut -f name "$SAKE_FILE" | sed 1d \
    | paste - <(mlr --csv cut -f cpu "$SAKE_FILE" | sed 1d) \
    | paste - <(mlr --csv cut -f cpu "$PYINFRA_FILE" | sed 1d) \
    | paste - <(mlr --csv cut -f cpu "$ANSIBLE_FILE" | sed 1d) \
    | sed 's/\t/,/g' >> "$CPU_FILE"

  echo "name,sake,pyinfra,ansible" > "$MEM_FILE"
  mlr --csv cut -f name "$SAKE_FILE" | sed 1d \
    | paste - <(mlr --csv cut -f mem "$SAKE_FILE" | sed 1d) \
    | paste - <(mlr --csv cut -f mem "$PYINFRA_FILE" | sed 1d) \
    | paste - <(mlr --csv cut -f mem "$ANSIBLE_FILE" | sed 1d) \
    | sed 's/\t/,/g' >> "$MEM_FILE"
}

function __main__() {
  parse_options $@

  echo "## Versions ##"
  echo "sake: " $(sake --version | head -n 1)
  echo "pyinfra: " $(pyinfra --version)
  echo "ansible: " $(ansible-playbook --version | head -n 1)
  echo

  echo "------------ Start Test Case 1 ------------"
  echo
  # Shell command
  case $SOFTWARE in
    sake)
      benchmark "test-case-1" "sake" run_sake "ping"
      ;;
    pyinfra)
      benchmark "test-case-1" "pyinfra" run_pyinfra "pyinfra-ping.py"
      ;;
    ansible)
      benchmark "test-case-1" "ansible" run_ansible "ping-playbook.yaml"
      ;;
    *)
      benchmark "test-case-1" "sake" run_sake "ping"
      benchmark "test-case-1" "pyinfra" run_pyinfra "pyinfra-ping.py"
      benchmark "test-case-1" "ansible" run_ansible "ping-playbook.yaml"
      ;;
  esac
  create_tables "test-case-1"
  echo "------------ End Test Case 1 --------------"
  echo

  echo "------------ Start Test Case 2 ------------"
  echo
  # Multiple Commands
  case $SOFTWARE in
    sake)
      benchmark "test-case-2" "sake" run_sake "setup"
      ;;
    pyinfra)
      benchmark "test-case-2" "pyinfra" run_pyinfra "pyinfra.py"
      ;;
    ansible)
      benchmark "test-case-2" "ansible" run_ansible "playbook.yaml"
      ;;
    *)
      benchmark "test-case-2" "sake" run_sake "setup"
      benchmark "test-case-2" "pyinfra" run_pyinfra "pyinfra.py"
      benchmark "test-case-2" "ansible" run_ansible "playbook.yaml"
      ;;
  esac
  create_tables "test-case-2"
  echo "------------ End Test Case 2 --------------"
  echo

  python3 graph.py
}

__main__ $@
