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


import json


# List of labels for columns
# Not all columns have to exist
COLUMN_LABELS = [
    'read_ios',
    'read_merges',
    'read_sectors',
    'read_ticks',
    'write_ios',
    'write_merges',
    'write_sectors',
    'write_ticks',
    'in_flight',
    'io_ticks',
    'time_in_queue',
    'discard_ios',
    'discard_merges',
    'discard_sectors',
    'discard_ticks',
    'flush_ios',
    'flush_ticks'
]


def get_diskstats(path='/proc/diskstats'):
    with open(path, 'r') as diskstats_file:
        diskstats_content = diskstats_file.read()

    return diskstats_content

def parse_diskstats_line(line):
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
    diskstats = get_diskstats()
    parsed = parse_diskstats(diskstats)
    print(json.dumps(parsed, indent=2))

if __name__ == '__main__':
    main()
