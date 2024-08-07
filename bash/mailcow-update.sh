#!/bin/bash

# Execute the first script with --check
./update.sh --check > output.txt

# Check if the output contains "No updates available"
if grep -q "No updates available" output.txt; then
    del output.txt
    echo "No updates available. Exiting."
    exit 0
else
    del output.txt
    echo "Updates available. Executing ./update.sh --force"
    ./update.sh --force
fi