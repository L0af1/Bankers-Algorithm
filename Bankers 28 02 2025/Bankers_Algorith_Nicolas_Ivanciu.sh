#!/bin/bash


read -p "Enter number of processes: " n # key value : 3
read -p "Enter number of resources: " m # also a key value : 3

echo "Enter available resources: "
read -a available  # captures the available resources from the user and stores them in an array (i think of this as putting money in a swear jar)

total_resources=(${available[@]}) # pretty much stores the original total system resources for reference

# ive used arrays to store Maximum Matrix, Allocation Matrix, and Need Matrix because users have to input data in a specific order
max=()
alloc=()
need=()

# this first inputs all the Maximum Matrix values at once                #643
echo "Enter the Maximum Matrix values (each row on a new line):"          #322
for ((a=0; a<n; a++)); do                                                 #433
    read -a max_row
    for ((b=0; b<m; b++)); do
        max[$((a * m + b))]=${max_row[b]}  # stores maximum demand of resource b for process a
    done
done

# then input all the Allocation Matrix values at once
echo "Enter the Allocation Matrix values (each row on a new line):"    #221
for ((a=0; a<n; a++)); do                                              #100
    read -a alloc_row                                                  #211
    for ((b=0; b<m; b++)); do
        alloc[$((a * m + b))]=${alloc_row[b]}  # stores allocated resource b for process a
        need[$((a * m + b))]=$((max[$((a * m + b))] - alloc[$((a * m + b))]))  # calculates the need for resource b of process a
    done
done

safe_sequence=()  #empty array to store the safe execution sequence of processes
finish=($(for ((a=0; a<n; a++)); do echo 0; done))  #this marks all processes as unfinished

# function to recalculate safe sequence
calculate_safe_sequence() {
    safe_sequence=()
    finish=($(for ((a=0; a<n; a++)); do echo 0; done))
    available_copy=(${available[@]}) # creates a copy of available resources to prevent incorrect updates
    while :; do
        found=false
        for ((a=0; a<n; a++)); do
            if [[ ${finish[a]} -eq 0 ]]; then  # if process isn't finished, check it
                safe=true
                for ((b=0; b<m; b++)); do
                    [[ ${need[$((a * m + b))]} -gt ${available_copy[b]} ]] && safe=false && break  # If it needs more than available, not safe
                done
                if $safe; then
                    for ((b=0; b<m; b++)); do
                        available_copy[b]=$((available_copy[b] + alloc[$((a * m + b))]))  # releases allocated resources
                    done
                    safe_sequence+=($a)  # this adds process to safe sequence
                    finish[a]=1  # marks process as finished
                    found=true
                fi
            fi
        done
        [[ $found == false ]] && break  # If no process can proceed, exit loop (very important, i had to add this because i was getting stuck in an infinite loop at some point so i had to add && break)
    done
}

calculate_safe_sequence  # initial calculation of safe sequence

if [[ "${finish[*]}" =~ 0 ]]; then # time to see if the system is safe or unsafe
    echo "System is in an unsafe state. No safe sequence exists. Deadlock detected. "
else
    echo "System is in a safe state. Safe sequence: ${safe_sequence[@]} "

    # Handles adding more processes until system becomes unsafe
    while true; do
        echo "Do you want to add a new process? (yes/no): "
        read add_process
       
        if [[ "$add_process" == "no" ]]; then
            echo "Exiting safely... Bye bye! "
            break
        elif [[ "$add_process" != "yes" ]]; then
            echo "Invalid input. Please type 'yes' or 'no'."  # i don't like invalid inputs
            continue
        fi
       
        echo "Enter maximum demand for new process: "
        read -a new_max
       
        # ive removed allocated resources (set to zero) but kept max demand
        new_alloc=()
        for ((b=0; b<m; b++)); do
            new_alloc[b]=0
        done

        for ((b=0; b<m; b++)); do
            max+=(${new_max[b]})
            alloc+=(${new_alloc[b]})
            need+=(${new_max[b]}) # since the allocated resources is set to 0, need is equal to max demand
        done
       
        n=$((n + 1))  # increment process count
        finish+=0  # marks new process as unfinished
       
        echo "New process added. Recalculating safe sequence..."
        calculate_safe_sequence  # recalculate the sequence after adding a new process

        if [[ "${finish[*]}" =~ 0 ]]; then
            echo "System is now in an unsafe state. Deadlock detected. No more processes can be added. "
            break
        else
            echo "System remains in a safe state. Safe sequence: ${safe_sequence[@]} "
        fi
    done
fi

# Resources ive used to help me understand the Bankers Algorithm
    # https://www.geeksforgeeks.org/bankers-algorithm-in-operating-system-2/
    # https://www.youtube.com/watch?v=lMNrmDUJ3GY ( geeks for geeks video on the bankers algorithm)
    # https://www.youtube.com/watch?v=7qd5sqazD7k (this video was a great help because it showed me basics in bash)
    # https://www.youtube.com/watch?v=T0FXvTHcYi4 ( this video helped me understand what the bankers algorithm does)

    # how it should be tested:
     # 1. Enter number of processes: 3
     # 2. Enter number of resources: 3
     # 3 3 2
     # Maximum Matrix
     # 6 4 3
     # 3 2 2
     # 4 3 3
     # Allocation Matrix
     # 2 2 1
     # 1 0 0
     # 2 1 1
     # safe sequence: 1 2 0
     # enter new process yes/no?
     # yes
     # enter maximum demand?
     # 4 3 3
     #  blah blah blah sequence:  1 2 3 0

