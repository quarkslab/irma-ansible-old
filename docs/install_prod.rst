Production environment
======================

IRMA will be installed on physical servers.


Requirements
------------

- One or multiple 64-bit `Debian <https://www.debian.org>`_ 7 servers.

1. Prep servers
---------------

Create an account for Ansible provisioning, or use one which has already been
created. For speed up provisioning, you can:

- Authorize you SSH key for password-less authentication (optional):


.. code-block:: bash

    *On your local machine*
    $ ssh-copy-id user@hostname # -i if you want to select your identity file


- If you don’t want to have to type your password for `sudo` command execution,
  add your user to sudoers, using `visudo` command (optional):

.. code-block:: bash

    user ALL=(ALL) NOPASSWD: ALL


2. Configure you installation
-----------------------------

Modify settings in `playbooks/group_vars/*` especially the `default_ssh_keys:` section,
you’ll need to add private keys from user for password-less connection to the
default irma server user. *Be careful, you’ll need to change all passwords
from this configuration files (`password` variables for most of them).*

You’ll need to custom the `hosts/example` file and adapt it with you own server
infrastructure. There is three sections, one for each server role (frontend,
brain, probe).


3. Run the Ansible Playbook
---------------------------

To run the whole thing:

.. code-block:: bash

    $ ansible-playbook -i ./hosts/example playbooks/playbook.yml -u <your_sudo_username> -K

Ansible will ask you the sudo password (`-K` option),

To run one or more specific actions you can use tags. For example, if you want
to re-provision Nginx, run the same command, but add `--tags=nginx`. You can
combine multiple tags.


4. Modify .ini files
--------------------

You’ll need to connect on each server you’ve just used, and modify manually .ini
files.

In next release of this playbook, there’ll be more convenient way to automate
configuration generation.


5. Deploy new version of IRMA
-----------------------------

As your servers have been provision and deploy in step 5, when you want to upgrade
it, you’ll need to run the deployment script:

.. code-block:: bash

    $ ansible-playbook -i ./hosts/example playbooks/deployment.yml -u irma


/!\ Replace `irma` with the default user if you’ve change it in the
`playbooks/group_vars/all` file.


6. Access to your IRMA installation
-----------------------------------

Access to your installation using the hostname you’ve used as frontend hostname.
