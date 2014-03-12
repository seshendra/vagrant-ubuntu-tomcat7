# Java/J2EE development environment

This vagrant image will kick start your development in a self contained ubuntu precise32 box with all the neccessities installed. The developers just need to configure their eclipse to the shared tomcat filesystem and it's "hakuna matata" all over!
Will add more instructions with a sample project in the next few days.

## Pre-requisites
Ensure you have the following tools installed:
* virtualbox - https://www.virtualbox.org/
* vagrant - http://www.vagrantup.com/
* URL to current apache-tomcat-7.x.x.tar.gz (Ex http://apache.mirrors.pair.com/tomcat/tomcat-7/v7.0.50/bin/apache-tomcat-7.0.52.tar.gz)
	* Update the `$tomcat_url` definition in `manifests/default.pp` if the url is out of date.
* librarian-puppet - https://github.com/rodjek/librarian-puppet
	* puppet installation is optional, the modules have been added as gitsubmodules and pushed to the repo. It's necessary only if you think the modules are outdated

## Vagrant Setup
###Do the following:
* $ ```vagrant box add precise32 http://files.vagrantup.com/precise32.box```
	* This will download the VM for you
* $ ```git clone https://github.com/seshendra/vagrant-ubuntu-tomcat7.git```
	* clone this repoistory (it's your working vagrant location)
* **If librarian-puppet is installed**, grab the puppet modules:
	* $ ```cd vagrant-ubuntu-tomcat7/manifests```
	* $ ```librarian-puppet install```
	* $ ```cd ..```

* Otherwise, **if librarian-puppet is not installed**, clone the puppet modules
	* $ ```cd vagrant-ubuntu-tomcat7```
	* $ ```git submodule init```
  	* $ ```git submodule update```

* $ ```vagrant up```
	* brings up the VM with tomcat and java installed.
	* This can take anywhere between 20-30 minutes, so issue the command and go have some coffee or attend a meeting or watch a video while vagrant does it's job.
	* If you are in a VPN, ensure *ubuntu.com and *apache.com are open for downloads in your organization.
* $ ```vagrant ssh```
	* Login to your instance.

## Deployment Details
* Tomcat is set at auto-start to false
  * use ```sudo supervisorctl start tomcat``` to start tomcat
* Vagrant is setup to map port 8080 of the VM to port 4880 on your machine
	*  http://localhost:4880/

## Package as a box for customizing in your projects
* After box is configured and provisioned, you can package and use this as your base box to speed up your subsequent reloads
* ```vagrant package```
* ```mv package.box precise32-maven-tomcat7.box```
* ```vagrant box add precise32-maven-tomcat7 precise32-maven-tomcat7.box```
* Use ```precise32-maven-tomcat7``` as the name of the box in your VagrantFile ```config.vm.box = "precise32-maven-tomcat7"```
