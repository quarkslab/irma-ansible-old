FROM ansible/ubuntu14.04-ansible:stable

RUN mkdir /tmp/install/
WORKDIR /tmp/install/

RUN apt-get update && apt-get -y install git
RUN git clone https://github.com/quarkslab/irma-ansible.git
WORKDIR /tmp/install/irma-ansible/

ADD hosts/irma ./hosts/irma
ADD playbooks/provisioning.yml ./playbooks/provisioning.yml

ADD ansible-requirements.yml ansible-requirements.yml
RUN ansible-galaxy install -r ansible-requirements.yml


ADD ./roles/quarkslab.irma_provisioning_common/tasks/main.yml roles/quarkslab.irma_provisioning_common/tasks/main.yml
ADD ./roles/quarkslab.nodejs/tasks/main.yml roles/quarkslab.nodejs/tasks/main.yml
ADD ./playbooks/group_vars/frontend.yml playbooks/group_vars/frontend.yml
ADD ./roles/quarkslab.pureftpd/tasks/install.yml roles/quarkslab.pureftpd/tasks/install.yml
ADD ./roles/quarkslab.pureftpd/tasks/main.yml roles/quarkslab.pureftpd/tasks/main.yml
ADD ./roles/quarkslab.pureftpd/tasks/package.yml roles/quarkslab.pureftpd/tasks/package.yml
ADD ./roles/quarkslab.pureftpd/defaults/main.yml roles/quarkslab.pureftpd/defaults/main.yml
ADD ./roles/quarkslab.irma_provisioning_brain/handlers/main.yml roles/quarkslab.irma_provisioning_brain/handlers/main.yml
ADD ./roles/quarkslab.irma_deployment_frontend/tasks/main.yml roles/quarkslab.irma_deployment_frontend/tasks/main.yml
ADD ./roles/quarkslab.irma_deployment_probe/tasks/main.yml roles/quarkslab.irma_deployment_probe/tasks/main.yml
ADD ./roles/quarkslab.irma_deployment_brain/tasks/main.yml roles/quarkslab.irma_deployment_brain/tasks/main.yml
ADD ./roles/quarkslab.avg/tasks/main.yml roles/quarkslab.avg/tasks/main.yml
ADD ./roles/quarkslab.bitdefender/tasks/install.yml roles/quarkslab.bitdefender/tasks/install.yml

ADD ./roles/quarkslab.virusblokada/defaults/main.yml roles/quarkslab.virusblokada/defaults/main.yml

WORKDIR /

RUN mkdir /var/log/mongodb
RUN touch /var/log/mongodb/mongod.log

WORKDIR /tmp/install/

ENV ANSIBLE_FORCE_COLOR true
ENV PYTHONPATH "/opt/irma/irma-probe/current/"
ENV HOSTNAME irma

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN cd /tmp/install/irma-ansible && ansible-playbook -vvv -i /tmp/install/irma-ansible/hosts/irma /tmp/install/irma-ansible/playbooks/playbook.yml -c local

# These 3 lines are for the probes
# connect the probe to the brain
RUN sed -i 's/brain.irma/irma/' /opt/irma/irma-probe/current/config/probe.ini
RUN sed -i "s/nodaemon = false/nodaemon = true/" /etc/supervisord.conf

ADD ./docker/probe/supervisord.conf /supervisord.conf

RUN chmod 755 /usr/local/uvscan/uvscan
ENV TERM dumb

ENTRYPOINT ["/usr/local/bin/supervisord", "-c", "/supervisord.conf"]
