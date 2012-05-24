#!/usr/bin/env python

# usage: $0 source_dir dest_dir

import pexpect
import os, sys
import requests
import time

def new_dir(email,passwd,friends_email,tmppass):
	child = pexpect.spawn('encfs %s %s' %("/home/hr/src", "/home/hr/dest"))

	child.expect("Creating new encrypted volume.\r\n")
	child.expect("Please choose from one of the following options:\r\n")
	child.expect(" enter \"x\" for expert configuration mode,\r\n")
	child.expect(" enter \"p\" for pre-configured paranoia mode,\r\n")
	child.expect(" anything else, or an empty line will select standard mode.\r\n")
	child.expect("\?\> ")

	child.sendline('p')

	child.expect("Choose the number of users who will be using this\r\n")
	child.expect("folder, if it is going to be shared \(default: 1\)\r\n")
	child.expect("\?\> ")

	child.sendline('2')

	child.expect("Paranoia configuration selected.\r\n")
	child.expect("\r\n")
	child.expect("Configuration finished.  The filesystem to be created has\r\n")
	child.expect("the following properties:\r\n")
	child.expect("Filesystem cipher: \"ssl/aes\", version 3:0:2\r\n")
	child.expect("Filename encoding: \"nameio/block\", version 3:0:1\r\n")
	child.expect("Key Size: 256 bits\r\n")
	child.expect("Block Size: 1024 bytes, including 8 byte MAC header\r\n")
	child.expect("Each file contains 8 byte header with unique IV data.\r\n")
	child.expect("Filenames encoded using IV chaining mode.\r\n")
	child.expect("File data IV is chained to filename IV.\r\n")
	child.expect("File holes passed through to ciphertext.\r\n")
	child.expect("\r\n")
	child.expect("-------------------------- WARNING --------------------------\r\n")
	child.expect("The external initialization-vector chaining option has been\r\n")
	child.expect("enabled.  This option disables the use of hard links on the\r\n")
	child.expect("filesystem. Without hard links, some programs may not work.\r\n")
	child.expect("The programs 'mutt' and 'procmail' are known to fail.  For\r\n")
	child.expect("more information, please see the encfs mailing list.\r\n")
	child.expect("If you would like to choose another configuration setting,\r\n")
	child.expect("please press CTRL-C now to abort and start over.\r\n")
	child.expect("\r\n")
	child.expect("Now you will need to enter a password for your filesystem.\r\n")
	child.expect("You will need to remember this password, as there is absolutely\r\n")
	child.expect("no recovery mechanism.  However, the password can be changed\r\n")
	child.expect("later using encfsctl.\r\n")
	child.expect("\r\n")
	child.expect("You chose 2 users. Enter passphrase for user 1\r\n")
	child.expect("New Encfs Password: ")

	child.sendline(str(passwd))

	child.expect("Verify Encfs Password: ")

	child.sendline(str(passwd))

	child.expect("You chose 2 users. Enter passphrase for user 2\r\n")
	child.expect("New Encfs Password: ")

	child.sendline(str(tmppass))

	child.expect("Verify Encfs Password: ")

	child.sendline(str(tmppass))

	r = requests.post(("https://api.mailgun.net/v2/youcrypt.mailgun.org/messages"),
             auth=("api", "key-51pzkithdv41-pu7y70xelro2-2a6s76"),
             data={
                 "from": email,
                 "to": friends_email,
                 "subject": "Hello",
                 "text": "Your temp password is : "+str(tmppass)
                 }
        )
	print r

	time.sleep(4)