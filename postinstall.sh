#!/bin/bash

# Bashscript which is executed by bash *AFTER* complete installation is done
# (but *BEFORE* postupdate). Use with caution and remember, that all systems
# may be different! Better to do this in your own Pluginscript if possible.
#
# Exit code must be 0 if executed successfull.
#
# Will be executed as user "loxberry".
#
# We add 5 arguments when executing the script:
# command <TEMPFOLDER> <NAME> <FOLDER> <VERSION> <BASEFOLDER>
#
# For logging, print to STDOUT. You can use the following tags for showing
# different colorized information during plugin installation:
#
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

echo "<INFO> Downloading LoxBuddy App from https://github.com/nufke/loxbuddy..."
cd $LBPBIN/$pluginname
git clone https://github.com/nufke/loxbuddy
echo "Return Code is $?"
if [ -e "$LBPBIN/$pluginname/loxbuddy/package.json" ]; then
    echo "<OK> Download of LoxBuddy successfull."
else
    echo "<WARNING> Download of LoxBuddy failed. The plugin will not work without."
    echo "<WARNING> Giving up."
    exit 2
fi

# Install LoxBuddy
echo "<INFO> Installing LoxBuddy App..."
cd $LBPBIN/$pluginname/loxbuddy
npm install
echo "Return Code is $?"

# Install Icons
echo "<INFO> Downloading Loxone Icon Library from Miniserver..."
MSIP=$(perl -e "use LoxBerry::System;%miniservers=LoxBerry::System::get_miniservers();print \$miniservers{$1}{IPAddress};")
MSCRED=$(perl -e "use LoxBerry::System;%miniservers=LoxBerry::System::get_miniservers();print \$miniservers{$1}{Credentials};")
MSFTPPORT=$(perl -e "use LoxBerry::System; print LoxBerry::System::get_ftpport($1);")
FTPFULLURI="ftp://$MSCRED@$MSIP:$MSFTPPORT/sys/IconLibrary.zip"

mkdir -p $LBPBIN/$pluginname/loxbuddy/static/loxicons
cd $LBPBIN/$pluginname/loxbuddy/static/loxicons
wget $FTPFULLURI
echo "Return Code is $?"
if [ -e "$LBPBIN/$pluginname/loxbuddy/static/loxicons/IconLibrary.zip" ]; then
    echo "<OK> Download of Loxone IconLibrary successfull."
else
    echo "<WARNING> Download of IconLibrary failed. The plugin will not work without."
    echo "<WARNING> Giving up."
    exit 2
fi
unzip IconLibrary.zip
echo "Return Code is $?"
if [ -e "$LBPBIN/$pluginname/loxbuddy/static/loxicons/IconLibrary.xml" ]; then
    echo "<OK> Installing of Loxone IconLibrary successfull."
else
    echo "<WARNING> Installing of IconLibrary failed. The plugin will not work without."
    echo "<WARNING> Giving up."
    exit 2
fi

# Exit with Status 0
exit 0
