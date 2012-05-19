#!/usr/bin/env expect

expect "
expect "Please choose from one of the following options:"
expect " enter \"x\" for expert configuration mode,"
expect " enter \"p\" for pre-configured paranoia mode,"
expect " anything else, or an empty line will select standard mode."
expect "?> "

send "p"

expect "Choose the number of users who will be using this"
expect "folder, if it is going to be shared (default: 1)"

send "2"

expect ""
expect "Paranoia configuration selected."
expect ""
expect "Configuration finished.  The filesystem to be created has"
expect "the following properties:"
expect "Filesystem cipher: "ssl/aes", version 3:0:2"
expect "Filename encoding: "nameio/block", version 3:0:1"
expect "Key Size: 256 bits"
expect "Block Size: 1024 bytes, including 8 byte MAC header"
expect "Each file contains 8 byte header with unique IV data."
expect "Filenames encoded using IV chaining mode."
expect "File data IV is chained to filename IV."
expect "File holes passed through to ciphertext."
expect ""
expect "-------------------------- WARNING --------------------------"
expect "The external initialization-vector chaining option has been"
expect "enabled.  This option disables the use of hard links on the"
expect "filesystem. Without hard links, some programs may not work."
expect "The programs 'mutt' and 'procmail' are known to fail.  For"
expect "more information, please see the encfs mailing list."
expect "If you would like to choose another configuration setting,"
expect "please press CTRL-C now to abort and start over."
expect ""
expect "Now you will need to enter a password for your filesystem."
expect "You will need to remember this password, as there is absolutely"
expect "no recovery mechanism.  However, the password can be changed"
expect "later using encfsctl."
expect ""
expect "You chose 2 users. Enter passphrase for user 1"
expect "New Encfs Password:"

send "abcdef"

expect "Verify Encfs Password:"

send "abcdef"

expect "You chose 2 users. Enter passphrase for user 2"
expect "New Encfs Password:"

send "abcdef1"

expect "Verify Encfs Password:"

send "abcdef1"

