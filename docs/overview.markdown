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
