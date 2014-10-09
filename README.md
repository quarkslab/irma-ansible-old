IRMA Ansible Provisioning
=========================

This is a set of [Ansible](http://www.ansible.com) roles and playbooks that
can be used to build/install/maintain different setups for [IRMA](http://irma.quarkslab.com/)
platform.


Table of contents
-----------------

- [Quick start](#quick-start)
- [What You’ll need?](#what-youll-need)
- [Getting started](#getting-started)
- [Contributing](#contributing)
- [IRMA Community](#irma-community)
- [Credits](#credits)


Quick start
-----------

Three quick start options are available:
- Testing IRMA using virtual machines installed locally
- Installing IRMA in production
- Developing IRMA using virtual machines installed locally

What You’ll need?
-----------------

- [Ansible](http://www.ansible.com) 1.6 or higher;
- One or multiple 64-bit [Debian](https://www.debian.org) 7 servers. They should
  have been configured as mentioned in the prerequisites Section.

For *test or development* purposes (optional):

- [Vagrant](http://www.vagrantup.com/) 1.5 or higher has to be installed
- As the installation work only for [Virtualbox](https://www.virtualbox.org/),
  you’ll need to install it
- [Vagrant VBGuest](https://github.com/dotless-de/vagrant-vbguest) to speed up
  your VM
- [Rsync](https://rsync.samba.org/) to synchronize directories from host to VMs
- Read the [Ansible introduction](http://docs.ansible.com/intro.html)


Getting Started
---------------

### Testing IRMA, the easiest way

If you want to test IRMA, simply run in the `Vagrantfile` directory:

```
$ vagrant up
```

Vagrant will launch a VM and install IRMA on it. It can take a while
(from 15 to 30 min) depending on the amount of RAM you have on your computer
and the hard disk drive I/O speed.

Then, for proper use, update your `/etc/hosts` file and add:

```
172.16.1.30    www.frontend.irma
```

IRMA allinone is available at [www.frontend.irma](http://www.frontend.irma).


N.B.: If you want to test IRMA using multiple VMs, run:

```
$ VM_ENV=prod vagrant up
```

And then update your `/etc/hosts` file as mentioned above.


### Production environment

#### 1. Prep servers

Create an account for Ansible provisioning, or use one which has already been
created. For speed up provisioning, you can:

- Authorize you SSH key for password-less authentication (optional):

  ```
  *On your local machine*
  $ ssh-copy-id user@hostname # -i if you want to select your identity file
  ```

- If you don’t want to have to type your password for `sudo` command execution,
  add your user to sudoers, using `visudo` command (optional):

  ```
  user ALL=(ALL) NOPASSWD: ALL
  ```


### 2. Clone IRMA repository

Using [Git](http://git-scm.com/) software, clone the repository:
```
$ git clone --recursive
```


### 3. Configure you installation

Modify settings in `group_vars/*` especially the `default_ssh_keys:` section,
you’ll need to add private keys from user for password-less connection to the
default irma server user. *Be careful, you’ll need to change all passwords
from this configuration files (`password` variables for most of them).*

You’ll need to custom the `hosts` file and adapt it with you own server
infrastructure. There is three sections, one for each server role (frontend,
brain, probe). 


### 4. Install Ansible dependencies

Dependencies are available via [Ansible Galaxy](https://galaxy.ansible.com/)
repository. Installation has been made easy using:

```
$ ansible-galaxy install -r galaxy.yml -p ./roles # --force if you’ve already installed it
```


### 5. Run the Ansible Playbook

To run the whole thing:
```
$ ansible-playbook -i ./hosts playbook.yml -u <your_sudo_username> -K
```
Ansible will ask you the sudo password (`-K` option),

To run one or more specific actions you can use tags. For example, if you want
to re-provision Nginx, run the same command, but add `--tags=nginx`. You can
combine multiple tags.


### 6. Modify .ini files

You’ll need to connect on each server you’ve just used, and modify manually .ini
files.

In next release of this playbook, there’ll be more convenient way to automate
configuration generation.


### 7. Deploy new version of IRMA

As your servers have been provision and deploy in step 5, when you want to upgrade
it, you’ll need to run the deployment script:
```
$ ansible-playbook -i ./hosts deployment.yml -u irma
```

/!\ Replace `irma` with the default user if you’ve change it in the
`group_vars/all` file.


### 8. Access to your IRMA installation

Access to your installation using the hostname you’ve used as frontend hostname.


Test or develop IRMA using Vagrant
----------------------------------

### 1. Create the right environment

If you’re interested in using [Vagrant](http://vagrantup.com), be sure to have
the following directory layout:

```
… # all in the same directory
 |
 +--- irma-frontend
 +--- irma-probe
 +--- irma-brain
 [...]
 +--- irma-ansible-provisioning
```

Note: This directory layout can be modified, see `share_*` from
`environments/dev.yml` and `environments/allinone_dev.yml` files.


### 2. Run Vagrant and create your VMs

To initialize and provision the Virtualbox VM, run in the
irma-ansible-provisioning directory `vagrant up --no-provision`. VM will be
downloaded, and configured using `environments/dev.yml` file (default behavior).

(optional) If you want to use your own environment, create it in `environments`
directory and run:
```
$ VM_ENV=your_environment_name vagrant up --no-provision
```

### 3. Configure your .ini files

/!\ You can bypass this step, as this provisioning is sync with default username
and password used in (frontend|brain|probe) config files.

As your `config/*.ini` file are transferring from host to VMs, you’ll need
locally to modify it (frontend, probe, brain) to match `group_vars/*` user and
password.

In next release of this playbook, there’ll be more convenient way to automate
configuration generation.


### 4. Provision your VMs

Due to Ansible limitations using parallel execution, you’ll need to launch the
provision Vagrant command only for one VM:
```
$ vagrant provision frontend.irma
```

The provisioning and deployment will apply to all of your VMs.


### 5. Modify your host and open IRMA frontend

Then, for proper use, update your `/etc/hosts` file and add:
```
172.16.1.30    www.frontend.irma
```

Then, with your web browser, IRMA allinone is available at
[www.frontend.irma](http://www.frontend.irma).


Enable SSL using OpenSSL
------------------------

If you want to activate SSL on the frontend server, you’ll need:

- modify frontend_openssl variables in `group_vars/frontend`:

  ```
  frontend_openssl: True # Default is false
  frontend_openssl_dh_param: # put the DH file locations
  frontend_openssl_certificates: [] # an array of files {source, destination}
                                    # to copy to the server
  ```

- Uncomment (and customize) the `nginx_sites` variable in the
  `group_vars/frontend`, a commented example is available.

Then, provision or re-provision your infrastructure. Ansible will only change
file related to OpenSSL and Nginx configurations.


Speed up your Vagrant VMs
-------------------------

Install this softwares:
- [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier): `vagrant plugin
  install vagrant-cachier`
- [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest): `vagrant plugin
  install vagrant-vbguest`


Contributing
------------

Check the ”Test or develop IRMA using Vagrant” and feel free to submit pull
requests.


IRMA Community
--------------

Feel free to check out our IRC channel on Freenode #qb_irma, if you have
questions or any technical issues.


Credits
-------

Some of roles from [Ansible Galaxy](https://galaxy.ansible.com/) used here:
- MongoDB role from [Stouts/Stouts.mongodb](https://github.com/Stouts/Stouts.mongodb)
- NodeJS role from [JasonGiedymin/nodejs](https://github.com/AnsibleShipyard/ansible-nodejs)
- Nginx role from [jdauphant/ansible-role-nginx](https://github.com/jdauphant/ansible-role-nginx)
- OpenSSH role from [Ansibles/openssh](https://github.com/Ansibles/openssh)
- Sudo role from [weareinteractive/ansible-sudo](https://github.com/weareinteractive/ansible-sudo)
- Users role from [mivok/ansible-users](https://github.com/mivok/ansible-users)
- uWSGI role from [gdamjan/ansible-uwsgi](https://github.com/gdamjan/ansible-uwsgi)
