# Ubuntu Precise32 with Tomcat 7

## Pre-requisites
Ensure you have the following tools installed:
* virtualbox - https://www.virtualbox.org/
* vagrant - http://www.vagrantup.com/
* librarian-puppet - https://github.com/rodjek/librarian-puppet

## Vagrant Setup
Do the following:
* $ vagrant box add precise32 http://files.vagrantup.com/precise32.box
	* This will download the VM for you
* git clone https://github.com/seshendra/vagrant-ubuntu-tomcat7.git
	* clone this repoistory (it's your working vagrant location)
* $ cd vagrant-ubuntu-tomcat7/manifests
* $ librarian-puppet install
	* grabs the puppet modules for you
* $ cd ..
* $ vagrant up
	* brings up the VM with tomcat and java installed.

## Deployment Details
* Tomcat is set at auto-start to false
  * use ```sudo supervisorctl start tomcat``` to start tomcat
* Vagrant is setup to map port 8080 of the VM to port 4880 on your machine
	*  http://localhost:4880/
