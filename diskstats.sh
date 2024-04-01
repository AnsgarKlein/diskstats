#!/bin/bash

# MIT License
#
# Copyright (c) 2024 Ansgar Klein
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# This script reads statistics information about block devices from the
# kernel virtual filesystems.
# The column number being referred to in this script is the column in
# /sys/block/<device>/stat file. However this script actually reads
# /proc/diskstats file. /proc/diskstats contains the same columns as
# /sys/block/<device>/stat but contains information about *all* devices
# in a single file and starts with three extra columns.
#
# More information:
# https://www.kernel.org/doc/Documentation/ABI/testing/procfs-diskstats
# https://www.kernel.org/doc/Documentation/iostats.txt
# https://docs.kernel.org/block/stat.html
# https://docs.kernel.org/admin-guide/iostats.html


# Associative arrays storing different pieces of information
# about devices.
declare -A READ_IOS        # Col 1
declare -A READ_MERGES     # Col 2
declare -A READ_SECTORS    # Col 3
declare -A READ_TICKS      # Col 4
declare -A WRITE_IOS       # Col 5
declare -A WRITE_MERGES    # Col 6
declare -A WRITE_SECTORS   # Col 7
declare -A WRITE_TICKS     # Col 8
declare -A IN_FLIGHT       # Col 9
declare -A IO_TICKS        # Col 10
declare -A TIME_IN_QUEUE   # Col 11
declare -A DISCARD_IOS     # Col 12, since Kernel 4.18
declare -A DISCARD_MERGES  # Col 13, since Kernel 4.18
declare -A DISCARD_SECTORS # Col 14, since Kernel 4.18
declare -A DISCARD_TICKS   # Col 15, since Kernel 4.18
declare -A FLUSH_IOS       # Col 16, since Kernel 5.5
declare -A FLUSH_TICKS     # Col 17, since Kernel 5.5


# Get output of /proc/diskstats with removed whitespaces
# between columns
#
# Parameters: -
# shellcheck disable=SC2120
get_diskstats() {
    # Check parameters
    if [[ $# -ne 0 ]]; then
        echo 'get_diskstats()' > /dev/stderr
        echo "Expected exactly 0 parameters, $# given" > /dev/stderr
        exit 1
    fi

    if [[ ! -r '/proc/diskstats' ]]; then
        echo 'Error: /proc/diskstats not found or not readable!' > /dev/stderr
        exit 1
    fi
    local disk_stats
    disk_stats="$(cat /proc/diskstats)"
    disk_stats="$(echo "$disk_stats" | tr -s ' ')"

    echo "$disk_stats"
}


# Extract list of device names from /proc/diskstats
#
# Parameters:
#   $1: String containing content of /proc/diskstats
get_devices_from_diskstat() {
    # Check parameters
    if [[ $# -ne 1 ]]; then
        echo 'get_devices_from_diskstat()' > /dev/stderr
        echo "Expected exactly 1 parameters, $# given" > /dev/stderr
        exit 1
    fi
    local diskstats
    diskstats="$1"

    # Extract list of device names from 
    local devices
    devices="$(echo "$diskstats" | cut -d ' ' -f 4)"

    echo "$devices"
}


# Parse content of /proc/diskstats and save information
# in global variables
#
# Parameters:
#   $1: String containing content of /proc/diskstats
#   $2: Device to parse statistics for
parse_diskstats_for_device() {
    # Check parameters
    if [[ $# -ne 2 ]]; then
        echo 'parse_diskstats_for_device()' > /dev/stderr
        echo "Expected exactly 2 parameters, $# given" > /dev/stderr
        exit 1
    fi
    local diskstats
    diskstats="$1"
    local device
    device="$2"

    # Extract line for requested device from diskstats
    diskstats=$(echo "$diskstats" | grep " $device " | cut -d ' ' -f5-)

    # Count number of columns
    column_count=$(echo "$diskstats" | awk -F ' ' '{print NF}')

    # Extract statistics asynchronously using background jobs,
    # Command output gets sent to named pipe which we can later
    # (synchronously) use to get the output.
    exec 3< <(echo "$diskstats" | cut -d ' ' -f1)
    exec 4< <(echo "$diskstats" | cut -d ' ' -f2)
    exec 5< <(echo "$diskstats" | cut -d ' ' -f3)
    exec 6< <(echo "$diskstats" | cut -d ' ' -f4)
    exec 7< <(echo "$diskstats" | cut -d ' ' -f5)
    exec 8< <(echo "$diskstats" | cut -d ' ' -f6)
    exec 9< <(echo "$diskstats" | cut -d ' ' -f7)
    exec 10< <(echo "$diskstats" | cut -d ' ' -f8)
    exec 11< <(echo "$diskstats" | cut -d ' ' -f9)
    exec 12< <(echo "$diskstats" | cut -d ' ' -f10)
    exec 13< <(echo "$diskstats" | cut -d ' ' -f11)
    if [[ "$column_count" -ge 12 ]]; then
        exec 14< <(echo "$diskstats" | cut -d ' ' -f12)
    fi
    if [[ "$column_count" -ge 13 ]]; then
        exec 15< <(echo "$diskstats" | cut -d ' ' -f13)
    fi
    if [[ "$column_count" -ge 14 ]]; then
        exec 16< <(echo "$diskstats" | cut -d ' ' -f14)
    fi
    if [[ "$column_count" -ge 15 ]]; then
        exec 17< <(echo "$diskstats" | cut -d ' ' -f15)
    fi
    if [[ "$column_count" -ge 16 ]]; then
        exec 18< <(echo "$diskstats" | cut -d ' ' -f16)
    fi
    if [[ "$column_count" -ge 17 ]]; then
        exec 19< <(echo "$diskstats" | cut -d ' ' -f17)
    fi
    READ_IOS[$device]=$(cat <&3)
    READ_MERGES[$device]=$(cat <&4)
    READ_SECTORS[$device]=$(cat <&5)
    READ_TICKS[$device]=$(cat <&6)
    WRITE_IOS[$device]=$(cat <&7)
    WRITE_MERGES[$device]=$(cat <&8)
    WRITE_SECTORS[$device]=$(cat <&9)
    WRITE_TICKS[$device]=$(cat <&10)
    IN_FLIGHT[$device]=$(cat <&11)
    IO_TICKS[$device]=$(cat <&12)
    TIME_IN_QUEUE[$device]=$(cat <&13)
    if [[ "$column_count" -ge 12 ]]; then
        DISCARD_IOS[$device]=$(cat <&14)
    fi
    if [[ "$column_count" -ge 13 ]]; then
        DISCARD_MERGES[$device]=$(cat <&15)
    fi
    if [[ "$column_count" -ge 14 ]]; then
        DISCARD_SECTORS[$device]=$(cat <&16)
    fi
    if [[ "$column_count" -ge 15 ]]; then
        DISCARD_TICKS[$device]=$(cat <&17)
    fi
    if [[ "$column_count" -ge 16 ]]; then
        FLUSH_IOS[$device]=$(cat <&18)
    fi
    if [[ "$column_count" -ge 17 ]]; then
        FLUSH_TICKS[$device]=$(cat <&19)
    fi
}


# Output gathered information about devices
# in json format.
#
# Parameters: -
# shellcheck disable=SC2120
print_output() {
    # Check parameters
    if [[ $# -ne 0 ]]; then
        echo 'print_output()' > /dev/stderr
        echo "Expected exactly 0 parameters, $# given" > /dev/stderr
        exit 1
    fi

    # Extract list of devices from first statistics array
    # (they should all contain information about the same devices)
    local devices
    devices=()
    local dev
    for dev in "${!READ_IOS[@]}"; do
        devices+=("$dev")
    done
    unset dev

    # Put together json formated output string
    local output_str
    output_str='{\n'

    local device
    for i in "${!devices[@]}"; do
        local device="${devices[$i]}"
        output_str+="  \"$device\": {\n"
        output_str+="    \"read_ios\": ${READ_IOS[$device]},\n"
        output_str+="    \"read_merges\": ${READ_MERGES[$device]},\n"
        output_str+="    \"read_sectors\": ${READ_SECTORS[$device]},\n"
        output_str+="    \"read_ticks\": ${READ_TICKS[$device]},\n"
        output_str+="    \"write_ios\": ${WRITE_IOS[$device]},\n"
        output_str+="    \"write_merges\": ${WRITE_MERGES[$device]},\n"
        output_str+="    \"write_sectors\": ${WRITE_SECTORS[$device]},\n"
        output_str+="    \"write_ticks\": ${WRITE_TICKS[$device]},\n"
        output_str+="    \"in_flight\": ${IN_FLIGHT[$device]},\n"
        output_str+="    \"io_ticks\": ${IO_TICKS[$device]},\n"
        output_str+="    \"time_in_queue\": ${TIME_IN_QUEUE[$device]},\n"

        if [[ "${DISCARD_IOS[$device]}" ]]; then
            output_str+="    \"discard_ios\": ${DISCARD_IOS[$device]},\n"
        fi
        if [[ "${DISCARD_MERGES[$device]}" ]]; then
            output_str+="    \"discard_merges\": ${DISCARD_MERGES[$device]},\n"
        fi
        if [[ "${DISCARD_SECTORS[$device]}" ]]; then
            output_str+="    \"discard_sectors\": ${DISCARD_SECTORS[$device]},\n"
        fi
        if [[ "${DISCARD_TICKS[$device]}" ]]; then
            output_str+="    \"discard_ticks\": ${DISCARD_TICKS[$device]},\n"
        fi
        if [[ "${FLUSH_IOS[$device]}" ]]; then
            output_str+="    \"flush_ios\": ${FLUSH_IOS[$device]},\n"
        fi
        if [[ "${FLUSH_TICKS[$device]}" ]]; then
            output_str+="    \"flush_ticks\": ${FLUSH_TICKS[$device]},\n"
        fi

        # Remove last comma separating device statistics
        output_str="${output_str::-3}\n"
        output_str+="  }"

        # Append comma separating devices if device is not the last one
        if [[ "$(( i + 1 ))" -ne "${#devices[@]}" ]]; then
            output_str+=',\n'
        else
            output_str+='\n'
        fi
        unset device
    done

    output_str+="}"
    echo -e "$output_str"
}


main() {
    # Check that required tools are available
    local required_tools=(cat tr cut awk)
    for required_tool in "${required_tools[@]}"; do
        if ! command -v "$required_tool" &> /dev/null; then
            echo "Error: This script requires \"$required_tool\" to be available." > /dev/stderr
            echo "Installation should be possible through system package manager." > /dev/stderr
            exit 1
        fi
    done

    # Read /proc/diskstats
    local diskstats
    diskstats=$(get_diskstats)

    # Extract list of devices from /proc/diskstats
    local devices
    devices=$(get_devices_from_diskstat "$diskstats")

    # Parse line in /proc/diskstats for every device
    local device
    for device in $devices; do
        parse_diskstats_for_device "$diskstats" "$device"
    done

    print_output
}

main
