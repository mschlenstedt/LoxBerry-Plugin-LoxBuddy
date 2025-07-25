#!/bin/sh

# <OK> This was ok!"
# <INFO> This is just for your information."
# <WARNING> This is a warning!"
# <ERROR> This is an error!"
# <FAIL> This is a fail!"

# To use important variables from command line use the following code:
ARGV0=$0 # Zero argument is shell command
ARGV1=$1 # First argument is temp folder during install
ARGV2=$2 # Second argument is Plugin-Name for scipts etc.
ARGV3=$3 # Third argument is Plugin installation folder
ARGV4=$4 # Forth argument is Plugin version
ARGV5=$5 # Fifth argument is Base folder of LoxBerry

pluginname=$3

echo "<INFO> (Re-)Installing NodeJS..."
# Restarts Apache, so here not possible :-(
#/boot/dietpi/dietpi-software reinstall 9
cd /tmp
curl -sSfL https://raw.githubusercontent.com/MichaIng/nodejs-linux-installer/master/node-install.sh -o node-install.sh
chmod +x node-install.sh
./node-install.sh
rm node-install.sh

# Exit with Status 0
exit 0
