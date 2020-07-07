#!/usr/bin/expect
set ip [lindex $argv 0]
set timeout 20
spawn telnet $ip
expect "login: "
send "admin\r"
expect "Password:"
send "admin\r"
expect "SUCCESS"
expect "cli->"
send "sensor address\r"
expect cli->"
send "exit\r"
expect eof
