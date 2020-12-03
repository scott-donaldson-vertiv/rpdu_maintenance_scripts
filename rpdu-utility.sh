#!/bin/bash

# ---------------------------------------------------------------------------------------------
#
#  Copyright (c) 2015-2019, Avocent, Vertiv Infrastructure Ltd.
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#  3. All advertising materials mentioning features or use of this software
#   must display the following acknowledgement:
#   This product includes software developed by the Vertiv Co.
#  4. Neither the name of the Vertiv Co. nor the
#   names of its contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY VERTIV INFRASTRUCTURE LTD. ''AS IS'' AND ANY
#  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL Vertiv Infrastructure Ltd. BE LIABLE FOR ANY
#  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ---------------------------------------------------------------------------------------------

##
#
# Title:		RPDU Utility
# Description:  Scripts to collect configuration and change configuration properties for the 
#				Liebert(r) MPH2 & Avocent(r) MPX products.
# Version:		0.5
# Contributors:	scott.donaldson@vertiv.com, richard.hills@vertiv.com, mark.zagorski@vertiv.com,
#				philip.cotineau@vertiv.com
# Usage:		n/a
# Inputs:
#	CFG_TARGETIP_FILE
#

VERSION=0.5
CFG_FILE=./config/default.cfg
CFG_SCRIPTSPATH=${0%/*}

. $CFG_FILE
##
# Banner
#
echo -e '********************************************************************************\n*'
echo -e '*\tVertiv - RPDU Utility v$VERSION\n*'
echo -e '********************************************************************************'

##
#  Trap Handler
#
#  TODO: Kill spawned processes if mult-process enabled.
trap "echo -e 'Killing child processes.'; exit 2" SIGHUP SIGINT SIGTERM

function verify_payloads() {
  # TODO: Check execute rights and set them if needed.
  echo "[`date "+%Y%m%d-%H%M%S"`] [Debug]: Verify Payloads Not Implemented." >> $CFG_LOG_DIR/debug.log
}

##
#  Get General Device Information
#
function query_devices() {
	if [ -s $CFG_TARGETIP_FILE ]; then
		readarray -t targets < $CFG_TARGETIP_FILE
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Source file $CFG_TARGETIP_FILE" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Procesed targets ${targets[*]}" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Total Targets ${#targets[@]}" >> $CFG_LOG_DIR/debug.log
		total = ${#targets[@]}
		count = 0
		
		if [ ! -x "$(command -v expect)" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: expect package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: expect package is not installed." 10 40
			exit 3
		fi
		
		if [ ! -x "$CFG_PAYLOAD_DIR/rpc2/rpc2_info.exp" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: Expect script rpc2_info.exp is not permitted to execute." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: Expect script rpc2_info.exp is not permitted to execute." 10 40
			exit 4
		fi
		
		export RPC2_AUTH_USERNAME
		export RPC2_AUTH_PASS
		
		if [ -x "$(command -v ping)" ]; then

			echo $count | dialog --title "Query Devices ( $total )" --gauge "Querying..." 10 70 0
			for target in "${targets[@]}"
			do
				((count++))
				echo "[`date "+%Y%m%d-%H%M%S"`] Info: Querying $target"  >> $CFG_LOG_DIR/debug.log
				PCT=$((100*${count})/${total})
				echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Count $count" >> $CFG_LOG_DIR/debug.log
				echo $PCT | dialog --title "Query Devices ( $total )" --gauge "Querying $count..." 10 70 0
				
				ping -c 1 $target
				PING_SUCCESS=$?
				if [ $PING_SUCCESS -eq 0 ]; then 
					$CFG_PAYLOAD_DIR/rpc2/rpc2_info.exp $target | grep -v "cli->" > $CFG_OUTPUT/$target-info_`date "+%Y%m%d-%H%M%S"`.log
				fi
				sleep 2
			done
			
		else
			cat EOF | dialog --gauge "Querying..." 10 70 0
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: iputils package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: iputils package is not installed." 10 40
		fi

	else
		echo '[`date "+%Y%m%d-%H%M%S"`] [Error]: Target Devices Not Provided. File $CFG_TARGETIP_FILE does not exist.' >> $CFG_LOG_DIR/debug.log
	fi
	echo "[`date "+%Y%m%d-%H%M%S"`] [Info]: Completed."  >> $CFG_LOG_DIR/debug.log
}

##
#  Set SNMP v1/v2 Trap Destinations
#
function set_snmp_trap_dest() {
if [ -s $CFG_TARGETIP_FILE ]; then
		readarray -t targets < $CFG_TARGETIP_FILE
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Source file $CFG_TARGETIP_FILE" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Procesed targets ${targets[*]}" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Total Targets ${#targets[@]}" >> $CFG_LOG_DIR/debug.log
		total = ${#targets[@]}
		count = 0
		
		if [ ! -x "$(command -v expect)" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: expect package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: expect package is not installed." 10 40
			exit 3
		fi
		
		if [ ! -x "$CFG_PAYLOAD_DIR/rpc2/rpc2_snmp-v1v2c_create_trap.exp" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: Expect script rpc2_snmp-v1v2c_create_trap.exp is not permitted to execute." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: Expect script rpc2_snmp-v1v2c_create_trap.exp is not permitted to execute." 10 40
			exit 4
		fi
		
		export RPC2_AUTH_USERNAME
		export RPC2_AUTH_PASS
		export RPC2_TRAP_ENTRY
		export RPC2_TRAP_COMMUNITY
		export RPC2_TRAP_TGT_IPV4
		export RPC2_TRAP_HEARTBEAT
		export RPC2_TRAP_PORT
		
		if [ -x "$(command -v ping)" ]; then

			echo $count | dialog --title "Set Trap Destination ( $total )" --gauge "Querying..." 10 70 0
			for target in "${targets[@]}"
			do
				((count++))
				echo "[`date "+%Y%m%d-%H%M%S"`] Info: Setting $target"  >> $CFG_LOG_DIR/debug.log
				PCT=$((100*${count})/${total})
				echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Count $count" >> $CFG_LOG_DIR/debug.log
				echo $PCT | dialog --title "Setting Devices ( $total )" --gauge "Querying $count..." 10 70 0
				
				ping -c 1 $target
				PING_SUCCESS=$?
				if [ $PING_SUCCESS -eq 0 ]; then 
					$CFG_PAYLOAD_DIR/rpc2/rpc2_snmp-v1v2c_create_trap.exp $target | grep -v "cli->" > $CFG_OUTPUT/$target-create_trap_`date "+%Y%m%d-%H%M%S"`.log
				fi
				sleep 2
			done
			
		else
			cat EOF | dialog --gauge "Querying..." 10 70 0
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: iputils package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: iputils package is not installed." 10 40
		fi

	else
		echo '[`date "+%Y%m%d-%H%M%S"`] [Error]: Target Devices Not Provided. File $CFG_TARGETIP_FILE does not exist.' >> $CFG_LOG_DIR/debug.log
	fi
	echo "[`date "+%Y%m%d-%H%M%S"`] [Info]: Completed."  >> $CFG_LOG_DIR/debug.log
}

##
#  Enable SNMP v1/v2 All Notifications
#
function enable_snmp_all_notifications() {
if [ -s $CFG_TARGETIP_FILE ]; then
		readarray -t targets < $CFG_TARGETIP_FILE
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Source file $CFG_TARGETIP_FILE" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Procesed targets ${targets[*]}" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Total Targets ${#targets[@]}" >> $CFG_LOG_DIR/debug.log
		total = ${#targets[@]}
		count = 0
		
		if [ ! -x "$(command -v expect)" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: expect package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: expect package is not installed." 10 40
			exit 3
		fi
		
		if [ ! -x "$CFG_PAYLOAD_DIR/rpc2/rpc2_snmp-v1v2c_enable-all-traps.exp" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: Expect script rpc2_snmp-v1v2c_create_trap.exp is not permitted to execute." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: Expect script rpc2_snmp-v1v2c_enable-all-traps.exp is not permitted to execute." 10 40
			exit 4
		fi
		
		export RPC2_AUTH_USERNAME
		export RPC2_AUTH_PASS
		
		if [ -x "$(command -v ping)" ]; then

			echo $count | dialog --title "Set Trap Destination ( $total )" --gauge "Querying..." 10 70 0
			for target in "${targets[@]}"
			do
				((count++))
				echo "[`date "+%Y%m%d-%H%M%S"`] Info: Setting $target"  >> $CFG_LOG_DIR/debug.log
				PCT=$((100*${count})/${total})
				echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Count $count" >> $CFG_LOG_DIR/debug.log
				echo $PCT | dialog --title "Setting Devices ( $total )" --gauge "Querying $count..." 10 70 0
				
				ping -c 1 $target
				PING_SUCCESS=$?
				if [ $PING_SUCCESS -eq 0 ]; then 
					$CFG_PAYLOAD_DIR/rpc2/rpc2_snmp-v1v2c_enable-all-traps.exp $target | grep -v "cli->" > $CFG_OUTPUT/$target-create_trap_`date "+%Y%m%d-%H%M%S"`.log
				fi
				sleep 2
			done
			
		else
			cat EOF | dialog --gauge "Querying..." 10 70 0
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: iputils package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: iputils package is not installed." 10 40
		fi

	else
		echo '[`date "+%Y%m%d-%H%M%S"`] [Error]: Target Devices Not Provided. File $CFG_TARGETIP_FILE does not exist.' >> $CFG_LOG_DIR/debug.log
	fi
	echo "[`date "+%Y%m%d-%H%M%S"`] [Info]: Completed."  >> $CFG_LOG_DIR/debug.log
}


##
#  Set SNMP v1/v2 Community Strings
#
function set_community() {
	if [ -s $CFG_TARGETIP_FILE ]; then
		readarray -t targets < $CFG_TARGETIP_FILE
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Source file $CFG_TARGETIP_FILE" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Procesed targets ${targets[*]}" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Total Targets ${#targets[@]}" >> $CFG_LOG_DIR/debug.log
		total = ${#targets[@]}
		count = 0
		
		if [ ! -x "$(command -v expect)" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: expect package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: expect package is not installed." 10 40
			exit 3
		fi
		
		if [ ! -x "$CFG_PAYLOAD_DIR/rpc2/rpc2_snmp-v1v2c_create_community.exp" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: Expect script rpc2_snmp-v1v2c_create_community.exp is not permitted to execute." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: Expect script rpc2_snmp-v1v2c_create_community.exp is not permitted to execute." 10 40
			exit 4
		fi
		
		export RPC2_AUTH_USERNAME
		export RPC2_AUTH_PASS
		export RPC2_COMMUNITY_ENTRY
		export RPC2_COMMUNITY_NETWORK
		export RPC2_SNMP_COMMUNITY
		export RPC2_SNMP_COMMUNITY_MODE
		
		if [ -x "$(command -v ping)" ]; then

			echo $count | dialog --title "Set Community Devices ( $total )" --gauge "Querying..." 10 70 0
			for target in "${targets[@]}"
			do
				((count++))
				echo "[`date "+%Y%m%d-%H%M%S"`] Info: Setting $target"  >> $CFG_LOG_DIR/debug.log
				PCT=$((100*${count})/${total})
				echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Count $count" >> $CFG_LOG_DIR/debug.log
				echo $PCT | dialog --title "Setting Devices ( $total )" --gauge "Querying $count..." 10 70 0
				
				ping -c 1 $target
				PING_SUCCESS=$?
				if [ $PING_SUCCESS -eq 0 ]; then 
					$CFG_PAYLOAD_DIR/rpc2/rpc2_snmp-v1v2c_create_community.exp $target | grep -v "cli->" > $CFG_OUTPUT/$target-create_community_`date "+%Y%m%d-%H%M%S"`.log
				fi
				sleep 2
			done
			
		else
			cat EOF | dialog --gauge "Querying..." 10 70 0
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: iputils package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: iputils package is not installed." 10 40
		fi

	else
		echo '[`date "+%Y%m%d-%H%M%S"`] [Error]: Target Devices Not Provided. File $CFG_TARGETIP_FILE does not exist.' >> $CFG_LOG_DIR/debug.log
	fi
	echo "[`date "+%Y%m%d-%H%M%S"`] [Info]: Completed."  >> $CFG_LOG_DIR/debug.log
}


##
#  Restart Device/Controller
#
function reboot_device() {
if [ -s $CFG_TARGETIP_FILE ]; then
		readarray -t targets < $CFG_TARGETIP_FILE
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Source file $CFG_TARGETIP_FILE" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Procesed targets ${targets[*]}" >> $CFG_LOG_DIR/debug.log
		echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Total Targets ${#targets[@]}" >> $CFG_LOG_DIR/debug.log
		total = ${#targets[@]}
		count = 0
		
		if [ ! -x "$(command -v expect)" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: expect package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: expect package is not installed." 10 40
			exit 3
		fi
		
		if [ ! -x "$CFG_PAYLOAD_DIR/rpc2/rpc2_reboot.exp" ]; then
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: Expect script rpc2_reboot.exp is not permitted to execute." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: Expect script rpc2_reboot.exp is not permitted to execute." 10 40
			exit 4
		fi
		
		export RPC2_AUTH_USERNAME
		export RPC2_AUTH_PASS
		
		if [ -x "$(command -v ping)" ]; then

			echo $count | dialog --title "Restart Devices ( $total )" --gauge "Querying..." 10 70 0
			for target in "${targets[@]}"
			do
				((count++))
				echo "[`date "+%Y%m%d-%H%M%S"`] Info: Restarting $target"  >> $CFG_LOG_DIR/debug.log
				PCT=$((100*${count})/${total})
				echo "[`date "+%Y%m%d-%H%M%S"`] Debug: Count $count" >> $CFG_LOG_DIR/debug.log
				echo $PCT | dialog --title "Restarting Devices ( $total )" --gauge "Querying $count..." 10 70 0
				
				ping -c 1 $target
				PING_SUCCESS=$?
				if [ $PING_SUCCESS -eq 0 ]; then 
					$CFG_PAYLOAD_DIR/rpc2/rpc2_reboot.exp $target | grep -v "cli->" > $CFG_OUTPUT/$target-reboot_`date "+%Y%m%d-%H%M%S"`.log
				fi
				sleep 2
			done
			
		else
			cat EOF | dialog --gauge "Querying..." 10 70 0
			dialog --clear
			echo "[`date "+%Y%m%d-%H%M%S"`] [Error]: iputils package is not installed, this is a pre-requisite." >> $CFG_LOG_DIR/debug.log
			dialog --msgbox "Error: iputils package is not installed." 10 40
		fi

	else
		echo '[`date "+%Y%m%d-%H%M%S"`] [Error]: Target Devices Not Provided. File $CFG_TARGETIP_FILE does not exist.' >> $CFG_LOG_DIR/debug.log
	fi
	echo "[`date "+%Y%m%d-%H%M%S"`] [Info]: Completed."  >> $CFG_LOG_DIR/debug.log
}


##
#  Menu
#
while :
do
	cmd=(dialog  --backtitle "Vertiv - RPDU Utility v$VERSION" --title "Select Operation" --clear --menu "Select operation to perform with the arrow keys or the corresponding number keys." 16 44 8)
	options=(1 "Query Devices" \
			 2 "Configure Services" \
			 3 "Configure SNMP v1/v2 Access" \
			 4 "Configure SNMP v1/v2 Traps" \
			 5 "Configure Time" \
			 6 "Configure Network" \
			 7 "Reboot Devices" \
			 8 "Enable All SNMP Notifications" \
			 9 "Quit")
	choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	clear
	case $choice in
		1)	
			query_devices
			;;
		2)
			echo "Configure Services"
			;;
		3)
			echo "Configure SNMP v1/v2 Access"
			set_community
			;;
		4)
			echo "Configure SNMP v1/v2 Traps"
			set_snmp_trap_dest
			;;
		5)
			echo "Configure Time"
			;;
		6)
			echo "Configure Network"
			;;
		7)
			echo "Reboot Devices"
			reboot_device
			;;
		8)
			enable_snmp_all_notifications
			;;
		9)
			echo "Exiting."
			exit 1;;
	esac
done
