# Prerequisites

## VirtualBox

This tutorial leverages the [VirtualBox](https://www.virtualbox.org/) to streamline provisioning of the compute infrastructure required to bootstrap a Kubernetes cluster from the ground up. Click to [download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads).

### Vagrant

Use [Vagrant](https://www.vagrantup.com/) to manage virtual machine resources, use [vagrant-hosts](https://github.com/oscar-stack/vagrant-hosts) plugin to manage virtual machine resources `/etc/hosts` file.

```
vagrant plugin install vagrant-hosts
```

> output

```
Installing the 'vagrant-hosts' plugin. This can take a few minutes...
Installed the plugin 'vagrant-hosts (2.8.0)'!
```

Next: [Installing the Client Tools](02-client-tools.md)
