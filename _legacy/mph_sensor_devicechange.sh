#!/usr/bin/expect 
set ip [lindex $argv 0]
set timeout 20
spawn telnet $ip
expect "login: "
send "admin\r"
expect "Password:"
send "admin\r"
expect "SUCCESS"
expect "cli-> "
send "devicechange\r"
expect cli->"
send "devicechange acknowledge\r"
expect "cli->"
send "devicechange\r"
expect cli->"
send "sensor address\r"
expect cli->"
send "reboot\r"
expect "Proceed with reboot of all PDUs in the PDU Array (Y / N)\r"
send "Y\r"
send "exit\r"
expect eof
