#!/usr/bin/env python3

from argparse import ArgumentParser
import json
import subprocess
import sys


def execute_command(cmd): # type: (list) -> str
    """
    Execute given command str and return output
    """

    output = subprocess.check_output(cmd)
    return output.decode()

def compare_outputs(output1, output2): # type: (dict, dict) -> bool
    """
    Check if two given dicts have same content
    """

    if output1 == output2:
        return True
    return False

def main(): # type: () -> None
    # Parse arguments
    parser = ArgumentParser(
        description='Compares json output of two applications')
    parser.add_argument('--cmd1', nargs='+')
    parser.add_argument('--cmd2', nargs='+')
    args = parser.parse_args()

    # Execute both commands
    cmd1 = args.cmd1
    cmd2 = args.cmd2
    output1 = execute_command(cmd1)
    output2 = execute_command(cmd2)

    # Parse output
    dict1 = json.loads(output1)
    dict2 = json.loads(output2)

    # Compare outputs
    output_equal = compare_outputs(dict1, dict2)

    # Signal equality through exit code
    if not output_equal:
        print('Error: Output of given scripts are not equal!', file=sys.stderr)
        sys.exit(1)

    print('OK')
    sys.exit(0)

if __name__ == '__main__':
    main()
