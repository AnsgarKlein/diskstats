diskstats
=========

Script(s) that outputs content of `/proc/diskstats` in json format.
Useful for integrating in monitoring systems.


Bash vs Python
--------------

Script is available in two variants, one in pure Bash and one in pure Python 3.

Python version has no external dependencies and should work with *every* version
of Python 3.

For legacy or embedded systems that don't have a Python interpreter there is
an alternative, 100% compatible version in pure Bash. Make sure the system's
`/bin/bash` is a _true_ Bash interpreter, not Dash or Ash or similar.

There is some multithreading in the Bash version but it is still slower than the
Python script, so the Python script should be preferred if possible.


Info
----

| Column  | Identifier      | Supported since   | Description                                    |
| :-----: | :-------------- | :---------------- | :--------------------------------------------- |
|    1    |                 |                   | Major device number, ignored by this script    |
|    2    |                 |                   | Minor device number, ignored by this script    |
|    3    |                 |                   | Device name, used as identifier in JSON object |
|    4    | read_ios        |                   | Total number of reads completed successfully   |
|    5    | read_merges     |                   | Total number of reads merged (two reads next to each other have been merged to one) |
|    6    | read_sectors    |                   | Total number of sectors read successfully      |
|    7    | read_ticks      |                   | Total number of milliseconds spent reading     |
|    8    | write_ios       |                   | Total number of writes completed successfully  |
|    9    | write_merges    |                   | Total number of writes merged (two writes next to each other have been merged to one) |
|   10    | write_sectors   |                   | Total number of sectors written successfully   |
|   11    | write_ticks     |                   | Total number of milliseconds spent writing     |
|   12    | in_flight       |                   | Number of I/Os currently in progress           |
|   13    | io_ticks        |                   | Number of milliseconds spent doint I/O         |
|   14    | time_in_queue   |                   |                                                |
|   15    | discard_ios     | Linux Kernel 4.18 |                                                |
|   16    | discard_merges  | Linux Kernel 4.18 |                                                |
|   17    | discard_sectors | Linux Kernel 4.18 |                                                |
|   18    | discard_ticks   | Linux Kernel 4.18 |                                                |
|   19    | flush_ios       | Linux Kernel 5.5  |                                                |
|   20    | flush_ticks     | Linux Kernel 5.5  |                                                |


Deployment
----------

Both scripts have no "real" dependencies apart from their interpreter, the
Python standard library and some very basic command line tools.

Simply copy the script to the system you want to monitor and have your
monitoring system execute it.
