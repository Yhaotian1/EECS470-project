#!/bin/bash

set -eu

if [ $# -ne 2 ]; then
    echo "Usage: ./func/compare.sh <test_name> <compare_content = wb=1, out=2, mem=3, all=4>"
    exit 1
fi

TEST_NAME=$1
DIFF_TYPE=$2

FILE_TYPE="wb"
if [ $DIFF_TYPE -ne 1 ]; then
    FILE_TYPE="out"
fi

# Check if test file in final_project
P4_TEST_EXIST=`ls -l programs/ | grep $TEST_NAME | wc -l`
if [ $P4_TEST_EXIST -eq 0 ]; then
    echo "Test $TEST_NAME does not exist"
    exit 1
fi

# Find if the correct output file exists
if [ ! -f ../correct_output/$TEST_NAME.$FILE_TYPE ]; then
    cd ../project03

    # Check if the test file in project03
    TEST_EXTSTED=`ls -l programs/ | grep $TEST_NAME | wc -l`
    if [ $TEST_EXTSTED -eq 0 ]; then
        cp ../final_project/programs/$TEST_NAME.s programs/$TEST_NAME.s
    fi

    # Get the correct output
    make $TEST_NAME.out

    # Move the correct output to final_project
    mv output/$TEST_NAME.out  ../final_project/correct_output/$TEST_NAME.out
    mv output/$TEST_NAME.wb   ../final_project/correct_output/$TEST_NAME.wb
    mv output/$TEST_NAME.ppln ../final_project/correct_output/$TEST_NAME.ppln

    # Go Back
    cd ../final_project/
fi

# Get the correct output
make $TEST_NAME.out

if [ $DIFF_TYPE -eq 3 ]; then
    FILE_TYPE="mem"

    # Create the correct output file
    cat correct_output/$TEST_NAME.out | grep "@@@ mem" > correct_output/$TEST_NAME.$FILE_TYPE

    # Create the output file
    cat output/$TEST_NAME.out | grep "@@@ mem" > output/$TEST_NAME.$FILE_TYPE
fi

# Compare
diff -u correct_output/$TEST_NAME.$FILE_TYPE output/$TEST_NAME.$FILE_TYPE > output/$TEST_NAME.$FILE_TYPE.out.txt | true 

# Print the result
LINE_NUM=`cat output/$TEST_NAME.$FILE_TYPE.out.txt | wc -l`
if [ $LINE_NUM -eq 0 ]; then
    echo "@@@ $FILE_TYPE File is correct"
else
    echo "@@@ $FILE_TYPE File is wrong"
fi