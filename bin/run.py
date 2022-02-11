#!/usr/bin/env python3
# coding: utf-8

import sys
import json

std_input = sys.stdin.read()


def read_file(file_name):
    try:
        f = open(file_name, "r")
        sys.stdout.write(f.read())
        f.close()
    except ValueError as e:
        sys.exit(e)


if __name__ == "__main__":
    parse_input = json.loads(std_input)
    file_name = parse_input.get('data_file')
    read_file(file_name)
