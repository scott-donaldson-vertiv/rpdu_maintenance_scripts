#!/usr/bin/expect 
set CFG_TARGETIP_FILE target_list.txt
#set CFG_SCRIPTSPATH ${0%/*}
set CFG_CMD_TIMEOUT 20

puts "Avocent Professional Services PDU Utility'"

if { [file exists $CFG_TARGETIP_FILE] == 1} {
puts "File $CFG_TARGETIP_FILE Exist'"
set IP_ADDRESS_LIST_FILE [open $CFG_TARGETIP_FILE r]
set IP_ADDRESS_LIST [read $IP_ADDRESS_LIST_FILE]
    log_user 0
foreach i $IP_ADDRESS_LIST {
	spawn telnet $i
	expect "login: "
	send "admin\r"
	expect "Password:"
	send "admin\r"
	expect "SUCCESS"
	expect "cli-> "
	log_user 1
	puts $i
	send "sensor address\r"
	expect "cli->"
	log_user 0
	send "exit\r"
	expect eof
}
} else {
puts "File $CFG_TARGETIP_FILE dose not Exist'"
}