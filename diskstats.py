#!/usr/bin/env python3

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


"""
This script reads statistics information about block devices from the
kernel virtual filesystems.
The column number being referred to in this script is the column in
/sys/block/<device>/stat file. However this script actually reads
/proc/diskstats file. /proc/diskstats contains the same columns as
/sys/block/<device>/stat but contains information about *all* devices
in a single file and starts with three extra columns.

More information:
https://www.kernel.org/doc/Documentation/ABI/testing/procfs-diskstats
https://www.kernel.org/doc/Documentation/iostats.txt
https://docs.kernel.org/block/stat.html
https://docs.kernel.org/admin-guide/iostats.html
"""


import json


# List of labels for columns
# Not all columns have to exist
COLUMN_LABELS = [
    'read_ios',         # Col 1
    'read_merges',      # Col 2
    'read_sectors',     # Col 3
    'read_ticks',       # Col 4
    'write_ios',        # Col 5
    'write_merges',     # Col 6
    'write_sectors',    # Col 7
    'write_ticks',      # Col 8
    'in_flight',        # Col 9
    'io_ticks',         # Col 10
    'time_in_queue',    # Col 11
    'discard_ios',      # Col 12, since Kernel 4.18
    'discard_merges',   # Col 13, since Kernel 4.18
    'discard_sectors',  # Col 14, since Kernel 4.18
    'discard_ticks',    # Col 15, since Kernel 4.18
    'flush_ios',        # Col 16, since Kernel 5.5
    'flush_ticks'       # Col 17, since Kernel 5.5
]


def get_diskstats(path='/proc/diskstats'):
    """
    Returns content of diskstats file (/proc/diskstats by default)

    :param path: Path of diskstats file to read
    """

    with open(path, 'r') as diskstats_file:
        diskstats_content = diskstats_file.read()

    return diskstats_content

def parse_diskstats_line(line):
    """
    Parse single line of diskstats file and return content as
    tuple of devicename and dictionary containing all statistics.

    :param line: Content of single line of diskstats file to parse
    """

    # Split line into list of columns
    elements = line.split(' ')

    # Extract device name
    device = elements[2]

    # Remove first 3 columns (they specify the device)
    elements = elements[3:]

    # Extract all columns that are available, but not more
    # than we know the name for.
    column_count = min(len(elements), len(COLUMN_LABELS))

    # Create dict with label for every column
    output = {COLUMN_LABELS[i]: elements[i] for i in range(column_count)}

    return (device, output)

def parse_diskstats(diskstats):
    """
    Parse diskstats file and return content as dictionary from device
    name to dictionary from statistics name to statistics value.

    :param diskstats: Content of diskstats file to parse
    """

    lines = []
    for line in diskstats.split('\n'):
        # Replace duplicate whitespaces in line so columns are separated
        # by exactly one whitespace.
        line = ' '.join((word for word in line.split(' ') if word != ''))

        # Skip empty lines
        if line.strip() == '':
            continue

        lines.append(line)

    output = {}
    for line in lines:
        a, b = parse_diskstats_line(line)
        output[a] = b

    return output

def main():
    """
    Main function
    """

    diskstats = get_diskstats()
    parsed = parse_diskstats(diskstats)
    print(json.dumps(parsed, indent=2))

if __name__ == '__main__':
    main()