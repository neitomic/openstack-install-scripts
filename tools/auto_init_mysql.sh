#!/usr/bin/expect -f

set PASSWD_CUR [lindex $argv 1]
set PASSWD_NEW [lindex $argv 0]

spawn mysql_secure_installation
expect {Enter current password for root (enter for none):}
send "${PASSWD_CUR}\r"

# expect {Set root password?}
# send "Y\r"

#######################################################
# Another way:                                        #
# expect -exact "Change the root password? \[Y\/n\]"  #
#######################################################

expect {Change the root password?}
send "Y\r"
expect {New password:}
send "${PASSWD_NEW}\r"
expect {Re-enter new password:}
send "${PASSWD_NEW}\r"
expect {Remove anonymous users?}
send "Y\r"
expect {Disallow root login remotely?}
send "Y\r"
expect {Remove test database and access to it?}
send "Y\r"
expect {Reload privilege tables now?}
send "Y\r"
interact
