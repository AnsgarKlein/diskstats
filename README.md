[![CI](https://github.com/AnsgarKlein/diskstats/actions/workflows/ci.yml/badge.svg)](https://github.com/AnsgarKlein/diskstats/actions/workflows/ci.yml)

diskstats
=========

Bash/Python script that outputs content of `/proc/diskstats` in json format.
Useful for integrating in monitoring systems.


Usage
-----

Both scripts have no dependencies apart from their interpreter, the
Python standard library and some very basic command line tools.  
Simply copy the script to the system you want to monitor and have your
monitoring system execute it.

Output:

```json
{
  "sda": {
    "read_ios": 4664196,
    "read_merges": 2417352,
    "read_sectors": 138733701,
    "read_ticks": 1004515,
    "write_ios": 12415333,
    "write_merges": 9154818,
    "write_sectors": 378647202,
    "write_ticks": 22456835,
    "in_flight": 1,
    "io_ticks": 5209869,
    "time_in_queue": 24592896,
    "discard_ios": 252139,
    "discard_merges": 0,
    "discard_sectors": 289123992,
    "discard_ticks": 28198,
    "flush_ios": 1781543,
    "flush_ticks": 1103347
  },
  "sdb": {
    ...
  },
  ...
}
```

The fields correspond to the fields present in `/proc/diskstats` (see below).


Bash/Python implementation
--------------------------

Script is available in two variants, one in pure Bash and one in pure Python 3.

The Python version has no external dependencies and should work with every
version of Python 3.

For legacy or embedded systems that don't have a Python interpreter there is
an alternative, 100% compatible version in pure Bash. Make sure the system's
`/bin/bash` is a _true_ Bash interpreter, not Dash or Ash or similar.

There is some concurrency in the Bash version but it is still slower than the
Python script, so the Python script should be preferred if possible.


/proc/diskstats
---------------

The scripts read info from `/proc/diskstats`. It contains the following values
about a device in columns separated by whitespaces.

Values that are only available starting at a specific kernel version are
ignored if they don't exist.

| Column  | Identifier      | Supported since   | Description                                      |
| :-----: | :-------------- | :---------------- | :----------------------------------------------- |
|    1    |                 |                   | Major device number, ignored by this script      |
|    2    |                 |                   | Minor device number, ignored by this script      |
|    3    |                 |                   | Device name, used as identifier in JSON object   |
|    4    | read_ios        |                   | Total number of reads completed successfully     |
|    5    | read_merges     |                   | Total number of reads merged (two reads next to each other have been merged to one) |
|    6    | read_sectors    |                   | Total number of sectors read successfully        |
|    7    | read_ticks      |                   | Total number of milliseconds spent reading       |
|    8    | write_ios       |                   | Total number of writes completed successfully    |
|    9    | write_merges    |                   | Total number of writes merged (two writes next to each other have been merged to one) |
|   10    | write_sectors   |                   | Total number of sectors written successfully     |
|   11    | write_ticks     |                   | Total number of milliseconds spent writing       |
|   12    | in_flight       |                   | Number of I/Os currently in progress             |
|   13    | io_ticks        |                   | Number of milliseconds spent doint I/O           |
|   14    | time_in_queue   |                   |                                                  |
|   15    | discard_ios     | Linux Kernel 4.18 | Total number of discards completed successfully  |
|   16    | discard_merges  | Linux Kernel 4.18 | Total number of discards merged (two discards next to each other have been merged to one) |
|   17    | discard_sectors | Linux Kernel 4.18 | Total number of sectors discarded successfully   |
|   18    | discard_ticks   | Linux Kernel 4.18 | Total number of milliseconds spent discarding    |
|   19    | flush_ios       | Linux Kernel 5.5  | Total number of flushes completed successfully   |
|   20    | flush_ticks     | Linux Kernel 5.5  | Total number of milliseconds spent flushing      |

The same values are also available at `/sys/block/<device>/stat` without the
first 3 columns.
