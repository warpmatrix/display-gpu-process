#!/bin/bash
set -e

function is_owned_by_container() {
    local pid=$1
    local container_pid
    container_pid=$(pstree -s -p "$pid" | awk -F 'containerd-shim' '{print $2}' | awk -F '---' '{print $1}' | awk -F '[()]' '{print $2}')
    [[ -n $container_pid ]]
}

function get_container_owner() {
    local pid=$1
    local container_pid
    container_pid=$(pstree -s -p "$pid" | awk -F 'containerd-shim' '{print $2}' | awk -F '---' '{print $1}' | awk -F '[()]' '{print $2}')
    local container_id
    container_id=$(ps -p "$container_pid" -o args | tail -n +2 | awk -F '-id ' '{print $2}' | awk -F ' ' '{print $1}')
    docker ps --filter "id=$container_id" --format "{{.Names}}"
}

function get_process_owner() {
    local pid=$1
    # shellcheck disable=SC2009
    ps aux | grep "$pid" | grep -v "grep" | awk '{print $1}'
}

function set_owner_and_owner_type() {
    local pid=$1
    if is_owned_by_container "$pid"; then
        owner=$(get_container_owner "$pid")
        owner_type=container
    else
        owner=$(get_process_owner "$pid")
        owner_type=user
    fi
}

function print_device_info() {
    local pids=$(nvidia-smi --query-compute-apps=pid --format=csv,noheader | sort | uniq)
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "process" "used-memory (MiB)" "device-name" "device-bus" "owner" "owner-type" "running-time"
    # shellcheck disable=SC2048
    for pid in ${pids[*]}; do
        readarray -t used_memories < <(nvidia-smi --query-compute-apps=pid,used_memory --format=csv,nounits | grep "$pid" | awk -F ', ' '{print $2}')
        readarray -t device_names < <(nvidia-smi --query-compute-apps=pid,gpu_name --format=csv,nounits | grep "$pid" | awk -F ', ' '{print $2}')
        readarray -t device_bus_ids < <(nvidia-smi --query-compute-apps=pid,gpu_bus_id --format=csv,nounits | grep "$pid" | awk -F ', ' '{print $2}')
        local last_time=$(ps -p "$pid" -o etime --no-headers)
        set_owner_and_owner_type "$pid"
        paste -d ',' \
            <(printf "%s\n" "${used_memories[@]}") \
            <(printf "%s\n" "${device_names[@]}") \
            <(printf "%s\n" "${device_bus_ids[@]}") \
        | while IFS=',' read -r used_memory device_name device_bus_id; do
            printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$pid" "$used_memory" "$device_name" "$device_bus_id" "$owner" "$owner_type" "$last_time"
        done
    done
}

ip=$(hostname -I | awk '{print $1}')
printf "quering GPU usage for $ip, please wait for a few seconds...\n"
print_device_info | prettytable 7
