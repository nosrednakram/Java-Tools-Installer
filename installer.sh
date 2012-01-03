#!/bin/bash
#
# Copyright (c) 2010 Mark Anderson 
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
# following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
PATH=/bin:/usr/bin:/usr/sbin
HME=/tmp
SHELL=/bin/bash
export PATH HME SHELL
set -f -e -u -C 

MY_HOME=`pwd`

Options__add_apps=""
if [[ $UID -ne 0 ]]; then
   Options__base_dir="$HOME/java-tools"
else
   Options__base_dir="/opt/java-tools"
fi
Options__config_dir="config-files"
Options__config_file=""
Options__debug="FALSE"
Options__root_user="FALSE"
Options__source_dir="source-files"

opt_results=`getopt -s bash -o a:b:c:df:hrs: --long add_app:,base_dir:config_file:,config_dir:debug,help,root_usersource_dir: -- "$@"`

if test $? != 0 ; then
   echo "Unrecognized option error."
   exit 1
fi

eval set -- "$opt_results"

while true
do 
   case "$1" in
      -a|--add_app)
         Options__add_apps="$Options__add_apps $2";
         shift 2;
         ;;
      -b|--base_dir)
         Options__base_dir="$2";
         shift 2;
         ;;
      -c|--config_dir)
         Options__config_dir="$2";
         shift 2;
         ;;
      -d|--debug_level)
         Options__debug="TRUE";
         shift;
         ;;
      -f|--config_file)
         Options__config_file="$2";
         shift 2;
         ;;
      -h|--help)
        cat <<-EOHELP
		Usage: $0 
		
		Options:
		   -a or --add_app <Applicaiton Name>: Install listed application, more than one allowed
		   -b or --base_dir <Install Directory>: Base directroy to install all files under
		   -c or --config_dir <Config Directory>: Directory containin configuration files
		   -d or --debug: Turns on debugging output is supplied
		   -f or --config_file <Config File>: The configuration file is used
		   -h or --help: This massage
		   -r or --root_user: Add to alternatives and create file in /etc/profile.d for the applicaitons
		   -s or --source_dir: Directory to store/retrieve application files
		
		EOHELP
        exit 0
        ;;
      -r|--root_user)
         if [[ $UID -ne 0 ]]; then
            echo "$0 must be run as root when root option supplied"
            exit 1
         fi
         Options__root_user="TRUE";
         shift;
         ;;
       -s|--source_dir)
          Options__source_dir="$2";
          shift 2;
          ;;
       --)
         shift
         break;
         ;;
       *)
         if ! test "x$1" == "x" ; then 
            echo "$0 Unreasonable Option: \"$1\""
            exit 1
         else
            shift;
         fi
         ;;
    esac
done

if ! test "x$Options__config_file" = "x" ; then
   if test -f $Options__config_file ; then
      . $Options__config_file
   else
      echo Invalid Config File Sepcified
      exit 1
   fi
fi

if test "x$Options__config_dir" == "x" ; then
   echo Required configuration directory not specified
   exit 1
elif ! test -d "$Options__config_dir" ; then
   echo Invalid configuration directory specified
   exit 1
fi

if test "x$Options__base_dir" == "x" ; then
   echo "Required Base Directory not specified"
   exit 1
fi

if test "x$Options__add_apps" == "x" ; then
   Options__add_apps="INTERACTIVE"
fi

if ! test -d $Options__source_dir ; then
   read -r -p "Souce dir doesn't exist, create [Y/n] " response
   case $response in
      [yY][eE][sS]|[yY]) 
         mkdir -p $Options__source_dir
         ;;
      [nN][oO]|[nN])
         echo Exiting source dir is missing
         exit 1
         ;;
   esac
fi

if test "$Options__add_apps" == "INTERACTIVE" || test "$Options__add_apps" == " INTERACTIVE" ; then
   Options__add_apps=""
   for app in $(ls $Options__config_dir) ; do
      while true
      do
         read -r -p "Install $app? [Y/n] " response
         case $response in
            [yY][eE][sS]|[yY]) 
              Options__add_apps="$Options__add_apps $app";
              break;
              ;;
            [nN][oO]|[nN])
              break;
              ;;
         esac
      done
   done
elif test "$Options__add_apps" == "ALL" || test "$Options__add_apps" == " ALL"; then
   Options__add_apps=""
   for app in $(ls $Options__config_dir) ; do
      Options__add_apps="$Options__add_apps $app";
   done
else
   INVALID_ITEM_FOUND=0
   for app in $Options__add_apps ; do
      if ! test -f $Options__config_dir/$app ; then
         echo "$app not in $Options__config_dir directory."
         INVALID_ITEM_FOUND=1
      fi
   done
   if [ $INVALID_ITEM_FOUND -eq 1 ] ; then
      exit 1
   fi
fi

if test $Options__debug == "TRUE"  ; then
   echo "Installing as root:     $Options__root_user"
   echo "Debug:                  $Options__debug"
   echo "Config File:            $Options__config_file"
   echo "Install Config dir      $Options__config_dir"
   echo "Installing Into:        $Options__base_dir"
   echo "Where to store source:  $Options__source_dir"
   if ! test "x$Options__add_apps" == "x" ; then 
      echo "Installing Apps:"
      for app in $Options__add_apps ; do
         echo "    $app"
      done
   fi 
fi

ALL_NOTES=""
SETTINGS=""

for app in $Options__add_apps; do
    # Make sure we can get homa again
    cd $MY_HOME

    if test $Options__debug == "TRUE" ;  then
       echo Installing $app .....
    fi

    # Reset Variables
    ALTERNATIVES_VERSION=""
    APP_FILE=""
    APP_NAME=""
    APP_NOTES=""
    ENV_VAR=""
    EXTRACT_CMD=""
    EXTRACT_DIR=""
    GET_CMD=""

    # include file variables
    . $MY_HOME/$Options__config_dir/$app

    if ! test "x$APP_NOTES" == "x" ; then
       if test $Options__debug == "TRUE" ;  then
          echo "Appending APP_NOTES to ALL_NOTES"
       fi
       ALL_NOTES="$ALL_NOTES\n$APP_NOTES"
    fi

    # Verify Required Variables are Set

    if test $Options__debug == "TRUE" ;  then
       echo Verifying Required variables from config files
    fi

    if test "x$ALTERNATIVES_VERSION" == "x" ; then
       echo Required ALTERNATIVES_VERSION paramter missing from $app
       exit 2
    fi
    
    if test "x$APP_FILE" == "x" ; then
       echo Required APP_FILE paramter missing from $app
       exit 2
    fi
    
    if test "x$APP_NAME" == "x" ; then
       echo Required APP_NAME paramter missing from $app
       exit 2
    fi
    
    if test "x$ENV_VAR" == "x" ; then
       echo Required ENV_VAR paramter missing from $app
       exit 2
    fi
    
    if test "x$EXTRACT_CMD" == "x" ; then
       echo Required EXTRACT_CMD paramter missing from $app
       exit 2
    fi
    
    if test "x$EXTRACT_DIR" == "x" ; then
       echo Required EXTRACT_DIR paramter missing from $app
       exit 2
    fi
    
    if test "x$GET_CMD" == "x" ; then
       echo Required GET_CMD paramter missing from $app
       exit 2
    fi

    # Construnct additional variabls needed
    INSTALL_DIR=$Options__base_dir/$APP_NAME

    # See if a copy allready exists and if so move on
    if [ -d "$INSTALL_DIR/$EXTRACT_DIR" ] ; then
        echo $INSTALL_DIR/$EXTRACT_DIR allerady exists skipping!
        continue
    fi

    # Make the install dir for the app if missing and move into it
    mkdir -p $INSTALL_DIR
    cd $INSTALL_DIR

    # Copy the file from the source directory if possible otherwise
    # use the get command to fetch it.
    if [ -f $MY_HOME/$Options__source_dir/$APP_FILE ] ; then
       cp $MY_HOME/$Options__source_dir/$APP_FILE $INSTALL_DIR
    else
       $GET_CMD
    fi

    # Extract the application
    $EXTRACT_CMD

    # Move the application archive to the source directory if it doesn't
    # allready exist there in which case delete.
    if [ ! -f $MY_HOME/$Options__source_dir/$APP_FILE ] ; then
       mv $APP_FILE $MY_HOME/$Options__source_dir/.
    fi
    rm -f $APP_FILE

    # If we are running  as root and we can have the script install into the alternatives system
    # and create profile.d/app scripts.
    if test $Options__root_user == "TRUE" ; then

        alternatives --install /usr/lib/${APP_NAME}_home ${APP_NAME}home $INSTALL_DIR/$EXTRACT_DIR $ALTERNATIVES_VERSION
	
	    if [ ! -f /etc/profile.d/${APP_NAME}.sh ] ; then
	        cat <<-EOS > /etc/profile.d/${APP_NAME}.sh
			#
			# ${APP_NAME} configuration script
			#
			# This script is meant to be used with the alternatives system.
			#
			$ENV_VAR=/usr/lib/${APP_NAME}_home
			PATH=\$$ENV_VAR/bin:\$PATH
			export $ENV_VAR PATH
			EOS
	    fi
		
	    if [ ! -f /etc/profile.d/${APP_NAME}.csh ] ; then
	        cat <<-EOS > /etc/profile.d/${APP_NAME}.csh
			#
			# ${APP_NAME} configuration script
			#
			# This script is meant to be used with the alternatives system.
			#
			setenv $ENV_VAR /usr/lib/${APP_NAME}_home
			setenv PATH=\$$ENV_VAR/bin:\$PATH
			EOS
	    fi
   else 
      SETTINGS="$SETTINGS\n$ENV_VAR=$INSTALL_DIR/$EXTRACT_DIR"
      SETTINGS="$SETTINGS\nPATH=\$$ENV_VAR/bin:\$PATH\n"
   fi
done

echo -e "$ALL_NOTES"
echo -e "$SETTINGS"
