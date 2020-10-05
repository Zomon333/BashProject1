#!/bin/bash
# Project1 - The scripting project which gathers system information and displays it as an HTML file.

#Requirements:
#Discrete elements of information gathering (network, users, disk space etc...) are captured in script functions.
#Your code must be commented with both a header for the file as well as for each function.
#You should use a "Here" script (see the reading)
#Your code should require the user to run as root and error out gracefully with a message "Must Run as Root" displayed.
#You must have basic functions that implement:
	#Basic information on the linux distribution, kernel version, and CPU architecture (x86_64)
	#Free memory, physical and swap in human readable format
	#Disk information, listing of the disk devices and free space on any formatted partition
	#All users who have an interactive shell prompt to include what groups they are assigned
	#What is the system's primary IP address?
	#A report title that is eithe rpassed in or calculated within the shell script. Include a timestamp and username aswell.
	#You should add at least two more categories of information that are implemented in two or more script functions that gather other information that you think might be useful.

#### Root check
user=$(id -u)

if [ $user -eq 0 ]; then
	echo "You are a root user."
else
	echo "Must Run as Root"
	exit -1
fi

#### Sets default filename, but overwrites default in presence of positional parameter 1
filename=$1
if [ -z "$1" ]; then
	filename="Test.html"
fi


#### Constants

title="System Specifications for ${HOSTNAME}"
RIGHT_NOW="$(date +"%x %r %Z")"
TIME_STAMP="Updated on $RIGHT_NOW by $USER"

#### Functions

#Function to return HTML formatted hardware info
hardware_info()
{
	echo "<h2>System hardware</h2>"
	echo "<pre>"
	lshw
	echo "</pre>"
return 0
}

#Function to return HTML formatted CPU info
cpu_info()
{
	echo "<h2>CPU Informaion</h2>"
	echo "<pre>"
	lscpu
	echo "</pre>"
return 0
}

#Function to return HTML formatted memory info
memory_info()
{
	echo "<h2>Free system memory</h2>"
	echo "<pre>"
	free
	echo "</pre>"
return 0
}

#Function to return HTML formatted user list
user_info()
{
	echo "<h2>System users</h2>"
	echo "<pre>"
	less /etc/passwd | cut -d: -f1
	echo "</pre>"
return 0
}

#Function to return HTML formatted network info
network_info()
{
	echo "<h2>System network information & Local IP</h2>"
	echo "<pre>"
	netstat -r
	echo "</pre>"
return 0
}


#Function to return HTML formatted system information
system_info()
{
	if ls /etc/*release 1>/dev/null 2>&1; then
		echo "<h2>System release info</h2>"
		echo "<pre>"
		for i in /etc/*release; do
			head -n 1 "$i"
		done
		uname -orp
		echo "</pre>"
	fi
return 0
}

#Function to return HTML formatted system uptime
show_uptime()
{
	echo "<h2>System uptime</h2>"
	echo "<pre>"
	uptime
	echo "</pre>"
return 0
}

#Function to return HTML formatted drive
drive_space()
{
	echo "<h2>Filesystem space</h2>"
	echo "<pre>"
	df
	echo "</pre>"
return 0
}

#Function to return HTML formatted calculation of space at home directory
home_space()
{
	echo "<h2>Home directory space for $USER</h2>"
	echo "<pre>"
	echo "Bytes Directory"
	du -s /home/* | sort -nr #Must be run by the superuser
	echo "</pre>"
return 0
}

#### Main
cat << _EOF_ > "$filename"
<!DOCTYPE HTML>
	<html>
		<head>
			<title>$title</title>
			<meta charset="utf-8">
		</head>
		<body>
			<h1>$title:</h1>
			<p>$TIME_STAMP</p>
			$(system_info)
			$(user_info)
			$(show_uptime)
			$(memory_info)
			$(network_info)
			$(drive_space)
			$(home_space)
		</body>
	</html>
_EOF_

