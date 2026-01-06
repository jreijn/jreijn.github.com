---
comments: false
date: "2014-11-11T00:00:00Z"
title: Vagrant, provisioning and Puppet
aliases:
- using_vagrant_with_puppet
---

I still remember my early days with [Vagrant](http://vagrantup.com). I was amazed with how easy it was to create a new virtual machine from scratch. Remember those days when you had to mount an ISO or DVD before installing Linux in a VM? I'm happy that that belongs to the past now. 

I've been using Vagrant on and off over the last years and most of the time for 'simple' things, like creating bunch of VM's running a Couchbase or Elasticsearch cluster to use in combination with [Hippo CMS](http://www.onehippo.org). I think Vagrant is an ideal tool to test and run new software without having to pollute your own machine. Also clustering the machines is a breeze. By destroying the VM all the stuff that came along with a certain application is gone instantly. No more messy Macbook!

When I started out with Vagrant I usually created a Vagrant configuration based on a configuration written by somebody else. Most of the time I searched for what I needed on Github and when I found something I just cloned the project. There are so many Vagrant based projects available on Github, that you will probably find what you need quite easily.

The only problem I encountered with these projects in general was that every project had a different setup and used a different kind of provisioning system. The type of provisioning probably depended upon the personal or company preference of the user that maintained the repo. I quickly learned that it made sense to learn how these provisioning systems work.

## Getting started with provisioning

The official Vagrant documentation recommends to use shell based provisioning if you are new to both Vagrant and to the variety of  provisioning tools like [Puppet](http://puppetlabs.com/), [Chef](https://www.getchef.com/) or [Ansible](http://www.ansible.com/home). Using shell based provisioning in Vagrant is really simple. You can run inline shell scripts inside you Vagrantfile, but I always prefer to keep my configuration separate from my logic, so you can also just reference an external shell script by using the 'path' attribute.

``` ruby
Vagrant.configure("2") do |config|
  config.vm.provision "shell", path: "install-system-libraries.sh"
end
```

Where the install-system-libraries.sh would be just a simple bash file with some commands that could look something like:

``` bash
#!/bin/bash
/usr/bin/apt-get -y install imagemagick
/usr/bin/apt-get -y install libimage-exiftool-perl
```

As you can see the script is quite easy and it allows you to instruct the package manager of the OS to install some additional applications.

Using shell based provisioning is fine at first, but it does not allow you to re-use existing definitions, validations, utility method like checking distributions, application configurations, etc. You will have to write everything yourself in bash. For some cases this might be fine, but I really got the feeling quickly that the shell based provisioning was not something I would prefer even while using it just for local development.

I'm no expert when it comes to picking a provisioning tool. I chose to learn Puppet, since I had some talks with our Ops guys about it. Usually these provisioning tools are used to provision a large numbers of (virtual) machines. In my case I usually want to provision just one or a couple of machines. In case you are looking for inspiration on which provisioning tool you should learn first, you might get inspired by reading: [Community Metrics: Comparing Ansible, Chef, Puppet and Salt](http://redmonk.com/sogrady/2013/12/06/configuration-management-2013/).

## Getting started with Puppet in Vagrant

The quickest way to get started with the Puppet provisioner in Vagrant is to just enable it in your Vagrantfile:

``` ruby
Vagrant.configure("2") do |config|
  config.vm.provision "puppet"
end
```

By default, Vagrant will configure Puppet to look for manifest files in the "manifests" folder relative to the project root, and will use the "default.pp" manifest as an entry-point. This means, if your directory tree looks like the one below, you can get started with Puppet with just that one line in your Vagrantfile.

```
$ tree
.
|-- Vagrantfile
|-- manifests
|   |-- default.pp
```

Puppet programs are called “manifests,” and they use the .pp file extension. Puppet uses its own configuration language, which was designed to be accessible to sysadmins. The Puppet language does not require much formal programming experience and the [documentation](https://docs.puppetlabs.com/) is excellent.

Vagrant supports provisioning with [Puppet modules](https://docs.puppetlabs.com/guides/modules.html). Modules are reusable, sharable units of Puppet code. You can use modules to extend Puppet across your infrastructure by automating tasks such as setting up a database, web server, or mail server. Using modules can be done by specifying the path to a modules folder. The Puppet manifest file (default.pp) will always be used as the main entry-point for provisioning your VM's.

``` ruby
Vagrant.configure("2") do |config|
  config.vm.provision "puppet" do |puppet|
    puppet.module_path = "modules"
  end
end
```

These modules will then have to live locally within your project and will be located relative to your Vagrantfile on the filesytem. To get existing modules you can download the required modules (one by one) from the [Puppet Forge](https://forge.puppetlabs.com/) manually or use git submodules and reference the git repository of each module and it's dependencies. Even though they work, I think that both options are ugly. Since I want to use Puppet to automate things I think that having to do manual labour is annoying. If you choose to downloading them manually, you will also have to download the dependencies of the modules (and their dependencies). This takes quite some effort, which I think is a real pain.

It feels like back in the days when you had to copy your jar files into some lib folder while developing a Java app. These days we have things like Maven, Gradle and Ivy to handle this kind of dependency management for us.

## Using the Puppet Module Tool with a shell based provisioner

Now after some digging I found an interesting approach by using a combination of a shell script together with the Puppet Module Tool (PMT) and let the PMT first install the required Puppet modules before actually provisioning the VM with Puppet. This is an easy to adopt workflow if you just use Puppet to provision your development boxes. The Puppet configuration which I use right now looks close to this:

``` ruby
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--cpus", "2"]
    v.customize ["modifyvm", :id, "--memory", "1280"]
  end

  config.vm.provision "shell", path: "apt-update.sh"
  config.vm.provision "shell", path: "install-puppet-modules.sh"

  config.vm.provision :puppet do |puppet|
    #puppet.options = "--verbose --debug"
  end

end
```

First we update the box, then we install the modules with the ```install-puppet-modules.sh``` script, which uses the Puppet Module Tool to install my puppet dependencies. The shell script is quite simple and just checks to see of the modules are not already installed before installing the modules from the forge.

``` bash
#!/bin/bash
mkdir -p /etc/puppet/modules;

if [ ! -d /etc/puppet/modules/elasticsearch ]; then
  puppet module install elasticsearch-elasticsearch --version 0.4.0
fi
```

In the actual manifest file (default.pp) we can now just use the classes that became available from the above modules to actually provision the VM just like if you would download the modules manifest files manually. An example which installs Elasticsearch can look similar to:

``` ruby
class { 'elasticsearch':
  package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.deb',
  config => {
    'cluster.name' => 'project-cluster',
    'network' => {
        'host' => '0.0.0.0',
    }
  },
  java_install => true,
}

elasticsearch::instance { 'es-01': }

elasticsearch::plugin{'mobz/elasticsearch-head':
  module_dir => 'head',
  instances => [ 'es-01' ],
}

```

If you are new to Puppet and have been using shell based provisioning untill now you will probably notice you can do quite some advanced configurations within a Puppet manifest. In the above example which provisions Elasticsearch, I can easily change the Elasticsearch cluster name, determine the network interface it's listening on and add plugins all while provisioning the VM. Keep in mind that my example just touches a limited set of configuration options the elasticsearch Puppet module exposes.  

I was looking at a minimalistic approach to using a provisioning system. I did not want to install any plugins in Vagrant or having to learn the ins and outs of using Puppet modules, classes, resources and services. I've been quite happy with this setup so far. It seems to fit well with the way I'm working with Vagrant, VMs and software. Based on the above post I've created an example project. You can find my [elasticsearch-puppet](https://github.com/jreijn/vagrants/tree/master/elasticsearch-puppet) project on Github. I hope it can help you get started with Vagrant in combination with Puppet in an easy way.
