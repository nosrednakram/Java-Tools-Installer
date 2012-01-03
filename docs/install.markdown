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
