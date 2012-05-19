#!/usr/bin/env python

# usage: $0 source_dir dest_dir

import pexpect
import os, sys

child = pexpect.spawn('encfs %s %s' %(sys.argv[1], sys.argv[2]))

child.expect("Please choose from one of the following options:\n")
child.expect(" enter \"x\" for expert configuration mode,\n")
child.expect(" enter \"p\" for pre-configured paranoia mode,\n")
child.expect(" anything else, or an empty line will select standard mode.\n")
child.expect("?> ")

child.sendline('p')

