FROM ansible/ubuntu14.04-ansible:stable

RUN mkdir /tmp/install/
WORKDIR /tmp/install/

RUN apt-get update && apt-get -y install git
RUN git config --global user.email "nobody@nobody.com" && git config --global user.name "nobody" && git clone https://github.com/p-col/irma-ansible.git && cd irma-ansible && git pull origin docker && git checkout docker

WORKDIR /tmp/install/irma-ansible/

ADD docker/brain/hosts/irma ./hosts/irma
ADD playbooks/provisioning.yml ./playbooks/provisioning.yml

ADD ansible-requirements.yml ansible-requirements.yml
RUN ansible-galaxy install -r ansible-requirements.yml


ADD ./roles/quarkslab.irma_provisioning_common/tasks/main.yml roles/quarkslab.irma_provisioning_common/tasks/main.yml
ADD ./roles/quarkslab.nodejs/tasks/main.yml roles/quarkslab.nodejs/tasks/main.yml
ADD ./playbooks/group_vars/frontend.yml playbooks/group_vars/frontend.yml
ADD ./playbooks/group_vars/brain.yml playbooks/group_vars/brain.yml
ADD ./roles/quarkslab.pureftpd/tasks/install.yml roles/quarkslab.pureftpd/tasks/install.yml
ADD ./roles/quarkslab.pureftpd/tasks/main.yml roles/quarkslab.pureftpd/tasks/main.yml
ADD ./roles/quarkslab.pureftpd/tasks/package.yml roles/quarkslab.pureftpd/tasks/package.yml
ADD ./roles/quarkslab.pureftpd/defaults/main.yml roles/quarkslab.pureftpd/defaults/main.yml
ADD ./roles/quarkslab.irma_provisioning_brain/handlers/main.yml roles/quarkslab.irma_provisioning_brain/handlers/main.yml
ADD ./roles/quarkslab.irma_deployment_frontend/tasks/main.yml roles/quarkslab.irma_deployment_frontend/tasks/main.yml
ADD ./roles/quarkslab.irma_deployment_probe/tasks/main.yml roles/quarkslab.irma_deployment_probe/tasks/main.yml
ADD ./roles/quarkslab.irma_deployment_brain/tasks/main.yml roles/quarkslab.irma_deployment_brain/tasks/main.yml
ADD ./roles/quarkslab.apt/tasks/main.yml roles/quarkslab.apt/tasks/main.yml
ADD ./roles ./

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

RUN sed -i 's/brain.irma/127.0.0.1/' /opt/irma/irma-frontend/current/config/frontend.ini
RUN sed -i 's/brain.irma/127.0.0.1/' /opt/irma/irma-brain/current/config/brain.ini

RUN echo "39000 39020" > /etc/pure-ftpd/conf/PassivePortRange

EXPOSE 80
EXPOSE 8081
EXPOSE 21
EXPOSE 5672

WORKDIR /opt/irma/irma-brain/releases/current/extras/scripts/rabbitmq/

ADD ./docker/brain/supervisord.conf /supervisord.conf

ENTRYPOINT ["/usr/local/bin/supervisord", "-c", "/supervisord.conf"]
