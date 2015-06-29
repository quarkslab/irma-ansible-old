FROM ansible/ubuntu14.04-ansible:stable

#ADD ansible /srv/irma
#WORKDIR /srv/example

RUN mkdir /tmp/install/
WORKDIR /tmp/install/

RUN apt-get update && apt-get -y install git

#RUN apt-get update && apt-get install -y git openssh-server openssh-client make nodejs npm python-pip
RUN git clone https://github.com/quarkslab/irma-ansible.git

WORKDIR /tmp/install/irma-ansible/

ADD hosts/irma ./hosts/irma
#ADD playbooks/provisioning.yml ./playbooks/provisioning.yml
#ADD roles/quarkslab.irma_provisioning_common/tasks/hosts.yml ./roles/quarkslab.irma_provisioning_common/tasks/hosts.yml

RUN ansible-galaxy install -r ansible-requirements.yml
#RUN ls -l --color /tmp/install/irma-ansible/host

WORKDIR /

#RUN ln -s /usr/bin/nodejs /usr/bin/node
#RUN ls -l --color /usr/bin/node
#RUN ls -l --color /usr/bin/nodejs
#RUN nodejs --version
#RUN node --version

#RUN mkdir /var/log/mongodb
#RUN touch /var/log/mongodb/mongod.log
#RUN locale
#RUN groups

WORKDIR /tmp/install/

ENV ANSIBLE_FORCE_COLOR true

RUN cd /tmp/install/irma-ansible && ansible-playbook -vvv -i /tmp/install/irma-ansible/hosts/irma /tmp/install/irma-ansible/playbooks/playbook.yml -c local