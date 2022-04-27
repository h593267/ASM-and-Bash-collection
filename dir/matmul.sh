#!/bin/bash

# OBS!!! This is meant to be run with the MODIFIED MatMulASCII.java, since I have done subtask 3.
# DAT103 H2021 Obligatorisk innlevering 1 Arne Munthe-Kaas studnr. 593267

: '
    Written in vscode on Ubuntu 20.04.3 LTS on the UTM virtual machine on a Macbook air (M1, 2020) running macOS Big Sur 11.4
    Virtualbox did not work on my mac because of the non-intel/non-amd cpu, but I still wanted to do it on a virtual machine
    so I found https://mac.getutm.app/gallery/ubuntu-20-04 which supported my current hardware and software.

    Also tested in VSCode macOS Big Sur 11.4 - With changes to elapsed time taking commented out :-) Runs much slower on macOS
    as compared to on ubuntu virtual machine.
'

# Permissions if unable to run script "chmod u+x matmul.sh"

# Compile
javac MatMulASCII.java
#gcc toBinary.c -o toBinary

# Next few commented lines are from Subtask 1, but dont work properly after the changes made to MatMulASCII.java in Subtask 3

    # echo "Tests from subtask 1:"
    # For testing purposes in Subtask 1:
        # cat /dev/urandom | od | sed "s/\(.\)/\1 /g" | java MatMulASCII - OBS! This one doesnt work after subtask 3!
        # ./toBinary <<< "79 107 44 32 72 101 108 108 111 10"
    # echo "Tests completed!"
    # echo " "

# Actual script:

# If matmul.sh has been called with anything but 2 or 0 arguments
if [ "$#" -ne 2 ] && [ "$#" -ne 0 ]; then
    echo "Illegal number of parameters, matmul.sh must be ran with 0 or 2 parameters"
    echo "E.g. ./matmul.sh or ./matmul.sh A1.mat B1.mat"
    exit 1
fi

# If parameters = 2
if [ "$#" == 2 ]
then
    MAT1=$1
    MAT2=$2
    # Basenames (In case use of other directories for .mat files)
    B1="$(basename -- $1)"
    B2="$(basename -- $2)"

    # If matricies are input with only numbers e.g. ./matmul.sh 1
    if [[ "$MAT1" =~ ^[0-9]+$ ]] && [[ "$MAT2" =~ ^[0-9]+$ ]]
    then
        MAT1=A$MAT1.mat
        MAT2=B$MAT2.mat
        B1="$(basename -- $MAT1)"
        B2="$(basename -- $MAT2)"
    fi

    # Check if files exist, exit and display error if not found with list of all matrices in directory
    if [ ! -f $MAT1 ]; then
        echo "Error: file $MAT1 not found!"
        echo "Available matricies in directory:"
        ls *.mat
        exit 1
    fi

    if [ ! -f $MAT2 ]; then
        echo "Error: file $MAT2 not found!"
        echo "Available matricies in directory:"
        ls *.mat
        exit 1
    fi

    # If both matricies are A# or both are B#.
    if [ ${B1:0:1} == ${B2:0:1} ]
    then
        echo "Error: matmul.sh only accepts matrices of different types e.g. ./matmul.sh A1 B1"
        exit 1
    fi

    # Changes variables so if B# is input before A# they switch places
    if [ ${B1:0:1} == "B" ]
    then
        MAT3=$MAT1
        MAT1=$MAT2
        MAT2=$MAT3
    fi

    # Start timer
    # Ubuntu
        START=$(date +%s.%N)
    # macOS
        # start_ms=$(ruby -e 'puts (Time.now.to_f * 1000).to_i')

    # Run java program with specified matrices
    printf "Result: "
    cat $MAT1 $MAT2 | java MatMulASCII - Without piping!
    # cat $MAT1 $MAT2 | ./toBinary | java MatMulASCII # Piped through toBinary
else

    # Get all matricies that start with A or B
    AMATS=$(ls A*.mat)
    BMATS=$(ls B*.mat)

    # Start timer
    # Ubuntu
        START=$(date +%s.%N)
    # macOS
        # start_ms=$(ruby -e 'puts (Time.now.to_f * 1000).to_i')

    echo "Result for all matrix combinations:"
    # Loop through A-matricies
    for a in $AMATS
    do
        MAT1=$a

        # Inner loop through B-Matricies
        for b in $BMATS
        do
            MAT2=$b

            # Run java program with set matricies
            # cat $MAT1 $MAT2 | java MatMulASCII # - Without piping!
            cat $MAT1 $MAT2 | ./toBinary | java MatMulASCII # Piped through toBinary
        done
    done
fi

# End timer
END=$(date +%s.%N)

# Time difference in ms and echo result
# Ubuntu
    DIFF=$(echo "($END - $START)*1000" | bc)
    printf "Elapsed time: %0.2f ms \n" $DIFF # Format number to 2 decimal numbers
# macOS
    # end_ms=$(ruby -e 'puts (Time.now.to_f * 1000).to_i')
    # elapsed_ms=$((end_ms - start_ms))
    # echo "Elapsed time: $elapsed_ms ms"
    # echo " "
