% Java Tools Installer
% Mark Anderson
% 2012-01-02

The Java Tools Installer is a simle script that allow for the consistant and 
easy installation of defferent java based tools.  It's designed to specifically
automate the process of installing binary Java tools that have an *\*_HOME*
variable.  This works for grails, gant, ant, gradle, etc.

I noticed a consistant pattern with most of them.  It consisted of the follow
steps for each tool:

* Downloading
* Uncompressing
* Pointing a TOOL_HOME variable to the source directory
* Add to the **alternatives** system
* Create profile scripts that point to the **alternatives** home

To keep all of my installs consistant for developers, testers and on production
machines I felt some automation would be nice.  To this end I created 
the *Java Tools Installer*, which consists of a bash script that reads
configuration files for tools to install and installes them.

I belive anyone who uses Java based tools and needs to easily and consistantly install 
them.  Spcifically this is benificial to the following for the primary reasons
listed as well as more reasons that will be covered below:

Developers
    
  : Uses **alternatives** so developers can easily swich between versions

System Administrators

  : Automation keeps systems consistand and speeds up install process.

Test/QA

  : Makes build process automation easy so consistant testing is possible.
# Installing #

## Using curl ##

~~~~~~~~~~~~{.bash}
curl -L http://github.com/nosrednakram/Java-Tools-Installer/tarball/master | tar -xz
mv *nosrednakram-Java-Tools-Installer-* Java-Tools-Installer
cd Java-Tools-Installer
./installer.sh
~~~~~~~~~~~~

## Using git ##

~~~~~~~~~~~~{.bash}
git clone git://github.com/nosrednakram/Java-Tools-Installer.git
cd Java-Tools-Installer
./installer.sh
~~~~~~~~~~~~

The installer will use defaults for all opotions and prompt for which tools to
install.  You should look in the [user guide][user-guide] for more advanced usage and for 
help on creating configuration files and  optional tools installers.

[user-guide]: ./user-guide.html "User Guide"
# User Guide #

The main  goal of this guide is to help you get the most out the `Java Tools Installer`. It will cover not only
usage but also adding additional tools. If your interest is to get up and running as quicklly as possible you
can go to the [installing](#installing "Installing") section of the document and be up and running in minutes. If you want to learn about
the more advanced features of the tool continue on.

## Design Goals ##

Below are the primary goals I keep in mind while working on this script.  If you feel I am not achieving any of 
them please let me know.

* Make installation of Java tools easy
* Automate the process to minimize inconsistancy between systems
* Configure before starting the installs so interaction is not required once it starts installing
* Allow multiple versions of any tool
* Optionally configure to use the `alternatives` command
* Optionally create profile scripts for installed tools
* Store download source in the event we need to install again
* Use reasonable defaults with several configuration options
    * Allow Interactive selection of available install options
    * Allow config file selection of available install options
    * Allow all config options to be set on the command line.

## Options/Defaults ##

Like most applications help is built in if you need a quick reference.  Both short and long options are
acceptable as well as allowing all options to be specified in a configuration file, except for the name
of the configuratin file that is.  This guide will use the long option to hopefully add clarity to the
examples.

~~~~~~~~~~~~~~~~~~~{.bash}
./installer.sh --help
Usage: ./installer.sh

Options:
   -a or --add_app <Applicaiton Name>: Install listed application, more than one allowed
   -b or --base_dir <Install Directory>: Base directroy to install all files under
   -c or --config_dir <Config Directory>: Directory containin configuration files
   -d or --debug: Turns on debugging output is supplied
   -f or --config_file <Config File>: The configuration file is used
   -h or --help: This massage
   -r or --root_user: Add to alternatives and create file in /etc/profile.d for the applicaitons
   -s or --source_dir: Directory to store/retrieve application files
~~~~~~~~~~~~~~~~~~~

### -a or --add_app ###

This option can be used to add one or more tools to be installed.  The name of a tool should exactlly match
the file name in the configuration directory. Like all other options the name of the configuration directory
can be configured but by default it is `config-files`.  There are two additional options you can specify:

ALL

  : ALL will install all all tools found in the configuration directory

INTERACTIVE

  : Interactive will prompt for each tool found in the configuration directory and then install.

### -b or  --base_dir ###

This is the location where the tools will be installed.  By default `$HOME/java-tools` if you are not root
or `/opt/java-tools` if you are.

### -c or --config_dir ###

The directory that contains the installation configuration files for each tool. This is `config-files` by 
default.

### -d or --debug ###

This tuns on debuging which will generate a more verbose output.  It is off by default.

### -f or --config_file ###

Rather than using command line options you can do all your configuration in configurations file. Common examples
chould be for different environment like development/production or when different tools are needed on
different systems for any reason.  The default is to not use a configuration file.

### -h or --help ###

This will bring up the minimal help help displaying the options.  

### -r or --root_user ###

This does two things when specified. First it sets the system up to use the `alternatives` command and second 
it creates scripts in `/etc/profile.d` directory for each tool that set a home environment variable and prepend
to the PATH environment variable.

### -s or --source_dir ###

This is the directory where source download are moved to after installation.  This server two purposes:

* Keeps source if you need to install in another environment and the source in to accessable through the net. 
* Keeps you from downloading more than once if you want to install into more than one location on your system.

## Examples ##

A picture is worth a thousand words and and example is worth at least a few hundred.  The examples below are
for basic using covering from no options and with some of the most common options.

### Example 1 ###

This first example is the simpelest example and without providing a configuration
file or command options forces it into interactive mode.  To see more of what
is happening run the command with the -d or --debug option.  We start by asking
which tools should be installed by listing the file in the config-files
directory.  Then since it wasn't ran as root $HOME/java-tools was used as the
installation directory. If it had been ran as root /opt/java-tools would have
been used and the alternatives system would have been configured with tool
specific files being added in /etc/profile.d for each tool.  Since -r or 
--root_user wasn't used we output the PATH and HOME directory changes so you 
can easily cut and past them into your .bash_profile or other file of choice.

~~~~~~~~~~~~~~~~~~~~{.bash}
./installer.sh 
Install ant-1.8.2? [Y/n] no
Install elasticsearch-0.18.6? [Y/n] no
Install gant-1.9.7? [Y/n] yes
Install gradle-1.0-m6? [Y/n] no
Install grails-1.3.7? [Y/n] y
Install grails-2.0.0? [Y/n] y
Install groovy-1.8.4? [Y/n] n


GANT_HOME=/home/nosrednakram/java-tools/gant/gant-1.9.7
PATH=$GANT_HOME/bin:$PATH

GRAILS_HOME=/home/nosrednakram/java-tools/grails/grails-1.3.7
PATH=$GRAILS_HOME/bin:$PATH

GRAILS_HOME=/home/nosrednakram/java-tools/grails/grails-2.0.0
PATH=$GRAILS_HOME/bin:$PATH
~~~~~~~~~~~~~~~~~~~~

### Example 2 ###

If you re-run the same command and provide the same options you will see that
we will not overwrite and existing install and just let you know when a 
previously installed tool was re-requested to be installed.

~~~~~~~~~~~~~~~~~~~~{.bash}
./installer.sh
Install ant-1.8.2? [Y/n] n
Install elasticsearch-0.18.6? [Y/n] n
Install gant-1.9.7? [Y/n] y
Install gradle-1.0-m6? [Y/n] n
Install grails-1.3.7? [Y/n] y
Install grails-2.0.0? [Y/n] y
Install groovy-1.8.4? [Y/n] n
/home/nosrednakram/java-tools/gant/gant-1.9.7 allerady exists skipping!
/home/nosrednakram/java-tools/grails/grails-1.3.7 allerady exists skipping!
/home/nosrednakram/java-tools/grails/grails-2.0.0 allerady exists skipping!
~~~~~~~~~~~~~~~~~~~~

### Example 3 ###

If you want to install all applications in config_file directory you can use
the -a ALL option or specifiy it in the config file.  This if the output for 
-a ALL base on our previous environment from example 2.  As you can see we 
have an additional note because Elastic Search requires more configuration. 
Currenlty I don't have previsouns for extra configuration because it's often
specific to implementatin but will add if people request it.

~~~~~~~~~~~~~~~~~~~~~{.bash}
./installer.sh -a ALL
/home/nosrednakram/java-tools/gant/gant-1.9.7 allerady exists skipping!
/home/nosrednakram/java-tools/grails/grails-1.3.7 allerady exists skipping!
/home/nosrednakram/java-tools/grails/grails-2.0.0 allerady exists skipping!

Additional Setup Required for ElasticSearch see:

http://www.elasticsearch.org/tutorials/2010/07/01/setting-up-elasticsearch.html


ANT_HOME=/home/nosrednakram/java-tools/ant/apache-ant-1.8.2
PATH=$ANT_HOME/bin:$PATH

ES_HOME=/home/nosrednakram/java-tools/elasticsearch/elasticsearch-0.18.6
PATH=$ES_HOME/bin:$PATH

GRADLE_HOME=/home/nosrednakram/java-tools/gradle/gradle-1.0-milestone-6
PATH=$GRADLE_HOME/bin:$PATH

GROOVY_HOME=/home/nosrednakram/java-tools/groovy/groovy-1.8.4
PATH=$GROOVY_HOME/bin:$PATH
~~~~~~~~~~~~~~~~~~~~~

### Example 4 ###

This example shows using the -r command which be default installs into
*/opt/java-tools* but of corse can be overwritten.  I also turn on 
debugging and specify a single tool on the command line.

~~~~~~~~~~~~~~~~~~~~{.bash}
sudo ./installer.sh -d -r -a elasticsearch-0.18.6 
Installing as root:     TRUE
Debug:                  TRUE
Config File:            
Install Config dir      config-files
Installing Into:        /opt/java-tools
Where to store source:  source-files
Installing Apps:
    elasticsearch-0.18.6
Installing elasticsearch-0.18.6 .....
Appending APP_NOTES to ALL_NOTES
Verifying Required variables from config files

Additional Setup Required for ElasticSearch see:

http://www.elasticsearch.org/tutorials/2010/07/01/setting-up-elasticsearch.html
~~~~~~~~~~~~~~~~~~~~

The previous command also created prifile scripts in /etc/profile.d.

**elasticsearch.sh**

~~~~~~~~~~~~~~~~~~~~~{.bash}
cat /etc/profile.d/elasticsearch.sh 
#
# elasticsearch configuration script
#
# This script is meant to be used with the alternatives system.
#
ES_HOME=/usr/lib/elasticsearch_home
PATH=$ES_HOME/bin:$PATH
export ES_HOME PATH
~~~~~~~~~~~~~~~~~~~~~

**elasticsearch.csh**

~~~~~~~~~~~~~~~~~~~~~{.bash}
cat /etc/profile.d/elasticsearch.csh 
#
# elasticsearch configuration script
#
# This script is meant to be used with the alternatives system.
#
setenv ES_HOME /usr/lib/elasticsearch_home
setenv PATH=$ES_HOME/bin:$PATH
~~~~~~~~~~~~~~~~~~~~~

Display **alternatives** 

~~~~~~~~~~~~~~~~~~~~~{.bash}
alternatives --display elasticsearchhome
elasticsearchhome - status is auto.
 link currently points to /opt/java-tools/elasticsearch/elasticsearch-0.18.6
/opt/java-tools/elasticsearch/elasticsearch-0.18.6 - priority 186
Current `best' version is /opt/java-tools/elasticsearch/elasticsearch-0.18.6.
~~~~~~~~~~~~~~~~~~~~~

## Using Alternatives ##

Unlike java and other tools installed by the system we simply set the \*_HOME 
variable and prepend \*_HOME/bin to the PATH.  Where java uses alternitives to
link the binaries into /usr/bin.  I believe my approach is simpler and makes
it very simple to change version as demonstrated below.  

~~~~~~~~~~~~~~~~~~~~{.bash}
[nosrednakram@localhost docs]$ grails -version

Grails version: 2.0.0
[nosrednakram@localhost docs]$ sudo alternatives --config grailshome

There are 3 programs which provide 'grailshome'.

  Selection    Command
-----------------------------------------------
   1           /opt/java-tools/grails/grails-1.3.7
   2           /opt/java-tools/grails/grails-2.0.0.RC3
*+ 3           /opt/java-tools/grails/grails-2.0.0

Enter to keep the current selection[+], or type selection number: 1
[nosrednakram@localhost docs]$ grails
Welcome to Grails 1.3.7 - http://grails.org/
Licensed under Apache Standard License 2.0
Grails home is set to: /usr/lib/grails_home

No script name specified. Use 'grails help' for more info or 'grails interactive' to enter interactive mode
~~~~~~~~~~~~~~~~~~~~

This works because GRAILS_HOME points to /usr/lib/grails_home and the PATH points to
/usr/lib/grails_home/bin.  There is an additional link in /etc alternatives so
/usr/lib/grails_home points to /etc/alternatives/grailshome which in turn points to 
the actual location of the selected version.

~~~~~~~~~~~~~~
[nosrednakram@localhost docs]$ ll /usr/lib/grails_home
lrwxrwxrwx. 1 root root 28 Jan  3 06:51 /usr/lib/grails_home -> /etc/alternatives/grailshome
[nosrednakram@localhost docs]$ ll /etc/alternatives/grailshome
lrwxrwxrwx. 1 root root 35 Jan  3 06:51 /etc/alternatives/grailshome -> /opt/java-tools/grails/grails-1.3.7
[nosrednakram@localhost docs]$ sudo alternatives --config grailshome

There are 3 programs which provide 'grailshome'.

  Selection    Command
-----------------------------------------------
 + 1           /opt/java-tools/grails/grails-1.3.7
   2           /opt/java-tools/grails/grails-2.0.0.RC3
*  3           /opt/java-tools/grails/grails-2.0.0

Enter to keep the current selection[+], or type selection number: 3
[nosrednakram@localhost docs]$ ll /etc/alternatives/grailshome
lrwxrwxrwx. 1 root root 35 Jan  3 06:54 /etc/alternatives/grailshome -> /opt/java-tools/grails/grails-2.0.0

~~~~~~~~~~~~~~

## Tool Specification ##

The file name is used to identify the tool and version to install .  Below is the source 
for the `grails-2.0.0` installer configuration.  Each of the options in the configuration 
file are required.  Any optional parameters will be covered below. You need to export any
variable you set so they are available to the installer script.

~~~~~~~~~~~~~~~~~~{.bash}
APP_NAME=grails
ENV_VAR=GRAILS_HOME
GET_CMD='wget http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.0.0.zip'
APP_FILE=grails-2.0.0.zip
EXTRACT_DIR=grails-2.0.0
EXTRACT_CMD="unzip -q $APP_FILE"
ALTERNATIVES_VERSION=2009

export APP_NAME ENV_VAR GET_CMD APP_FILE EXTRACT_DIR EXTRACT_CMD ALTERNATIVES_VERSION
~~~~~~~~~~~~~~~~~~

### APP_NAME ###

This is the name of a primary application and should mach for all versions of the same tool.  It's
used to create a subdirectory under the root install directory to put all related versions into.

### ENV_VAR ###

The environment variable to set that point to where the tool is installed.

### GET_CMD ###

The command to execute to get the source file down.  Typically wget or curl.

### APP_FILE ###

The name of the file that is downloaded so we can uncompress it.

### EXTRACT_DIR ###

The directory the APP_FILE creates when extracted.

### EXTRACT_CMD ###

The command that will extract the source file.

### ALTERNATIVES_VERSION ###

The version number to register the application with. It must be an intiger and not start with a zero.

### APP_NOTES ###

The APP_NOTES are displayed after the installations are finished.  They are displayed with the 
**-e** option to echo so use escape characters for line feeds, tabs etc.

## Configuration File ##

You can create configuration files to help you run the script the same way every time if you
would like.  You specify the configuration file to use with the -f or --config_file option.
Below is an example file I included as java-conf to help get you started.

~~~~~~~~~~~~~~~~~~{.bash}
#
# Basic Configuration file example
#
# The Options__base_dir is where you want the root of the tools install directory.
#
# Each installable configuration file needs to be in the Options__config_dir directory
#
# Options__add_apps contains a space delimited list of applictions, if you want to install
# everything from the APP_CONFIG_DIR you can set it to ALL or to INTERACTIVE if you
# prefer to be prompted based on the configuration files in the APP_CONFIG_DIR.
#
# If Options__debug is set to TRUE debugging processing is output to the screen.
#
# Options__source_dir is where the downloaded source will be stored when finished.
#
# Options__root_user if set to TRUE will install as root and add to alternatives as
# well as adding profile scripts in /etc/profile.d
#
Options__add_apps=ALL
Options__base_dir=/opt/java-tools
Options__config_dir=config-files
Options__debug=TRUE
Options__source_dir=source-files
Options__root_user=FALSE

export Options__add_apps Options__base_dir Options__config_dir Options__debug Options__source_dir Options__root_user
~~~~~~~~~~~~~~~~~~

# Appendix A (tools) #

Below is a list of the tools I used while working on this project.  You **do not** need to insall any of them.
This list is included for others who are looking for development tools.

Fedora Linux <http://fedoraproject.org/> 

  : Base OS I am developed this script on.

pandoc <http://johnmacfarlane.net/pandoc/index.html>

  : Tool for generating documentation in several formats.

Adaptive CSS <http://adapt.960.gs/>
 
  : I use this to make the html documentation pages scale dynamically and look consistant.

vim <http://www.vim.org/>

  : The code and documentation was primaryilly edited in vim.

gedit <http://projects.gnome.org/gedit/>

  : Text editor used to do some minor editing of the documentation.

bash <http://www.gnu.org/software/bash/> 

  : The shell I wrote this in, and use when available.

alternatives <http://dailypackage.fedorabook.com/index.php?/archives/6-Wednesday-Why-The-Alternatives-System.html>

  : Optioanlly you can install java applications to use the alternatives system.
