#!/bin/bash
cd /Library/MakerBot
. virtualenv/bin/activate
./conveyor_cmdline_client.py "$@"
