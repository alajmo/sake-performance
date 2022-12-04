#!/bin/bash

# This file will remove everything after `## Results` in the README.md and then append some graphs, data and text

set -e

sed -i '/## Results/,$d' README.md

TIME_FILE_1="./results/test-case-1/csv/time.csv"
CPU_FILE_1="./results/test-case-1/csv/cpu.csv"
MEM_FILE_1="./results/test-case-1/csv/mem.csv"

TIME_FILE_2="./results/test-case-2/csv/time.csv"
CPU_FILE_2="./results/test-case-2/csv/cpu.csv"
MEM_FILE_2="./results/test-case-2/csv/mem.csv"

##### TEST CASE 1 #####
#
cat >> README.md <<- EOM
## Results

Complete benchmark results can be found [here](./results).

### Test Case 1

This is the test case where we run 1 raw shell command.

![time](./results/test-case-1/images/time.png)
![time](./results/test-case-1/images/cpu.png)
![time](./results/test-case-1/images/mem.png)

EOM

echo "Elapsed Time (seconds)" >> README.md
echo >> README.md
mlr --implicit-csv-header label "name","sake","pyinfra","ansible" --omd "$TIME_FILE_1" | sed '3d' >> README.md
echo >> README.md

echo "CPU (%)" >> README.md
echo >> README.md
mlr --implicit-csv-header label "name","sake","pyinfra","ansible" --omd "$CPU_FILE_1" | sed '3d' >> README.md
echo >> README.md

echo "Memory (MB)" >> README.md
echo >> README.md
mlr --implicit-csv-header label "name","sake","pyinfra","ansible" --omd "$MEM_FILE_1" | sed '3d' >> README.md
echo >> README.md

##### TEST CASE 2 #####

cat >> README.md <<- EOM
### Test Case 2

This is the test case where we run the following commands:

1. Install htop
2. Add a user
3. Add a file
4. Copy a file

Note the following:

- After the first command is ran, the subsequent commands won't do anything since the user and files already exists, so all the tasks are idempotent (even for sake)
- Ansible and pyinfra provide robust modules that handle a lot more edge-cases (and are prettier), whereas the ad-hoc written sake tasks only handles the basic cases (if not existing, add)

![time](./results/test-case-2/images/time.png)
![time](./results/test-case-2/images/cpu.png)
![time](./results/test-case-2/images/mem.png)

EOM

echo "Elapsed Time (seconds)" >> README.md
echo >> README.md
mlr --implicit-csv-header label "name","sake","pyinfra","ansible" --omd "$TIME_FILE_2" | sed '3d' >> README.md
echo >> README.md

echo "CPU (%)" >> README.md
echo >> README.md
mlr --implicit-csv-header label "name","sake","pyinfra","ansible" --omd "$CPU_FILE_2" | sed '3d' >> README.md
echo >> README.md

echo "Memory (MB)" >> README.md
echo >> README.md
mlr --implicit-csv-header label "name","sake","pyinfra","ansible" --omd "$MEM_FILE_2" | sed '3d' >> README.md
