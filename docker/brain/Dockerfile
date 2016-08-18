FROM debian:jessie

# Environment
ENV DEBIAN_FRONTEND noninteractive
ENV ANSIBLE_FORCE_COLOR true
ENV PYTHONPATH "/opt/irma/irma-probe/current/"
ENV HOSTNAME irma
ARG DOCKERBUILD=true

# Update
RUN apt-get update
RUN apt-get install -y python-pip python-dev python-setuptools libffi-dev libssl-dev git wget locales lsb-release
RUN pip install -U cffi ansible MarkupSafe cryptography

# Fix locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen && update-locale

# Copy install files
RUN mkdir /tmp/install/
ADD . /tmp/install/irma-ansible/
WORKDIR /tmp/install/irma-ansible/
ADD docker/brain/hosts/irma ./hosts/irma
ADD docker/brain/create_rabbit_irma_users.sh /usr/bin/create_rabbit_irma_users.sh

# Perform install
ADD ansible-requirements.yml ansible-requirements.yml
RUN ansible-galaxy install -r ansible-requirements.yml
WORKDIR /tmp/install/
RUN cd /tmp/install/irma-ansible && ansible-playbook -vvv -i /tmp/install/irma-ansible/hosts/irma /tmp/install/irma-ansible/playbooks/playbook.yml -c local

# Post-install fixes
RUN sed -i 's/brain.irma/127.0.0.1/' /opt/irma/irma-frontend/current/config/frontend.ini
RUN sed -i 's/brain.irma/127.0.0.1/' /opt/irma/irma-brain/current/config/brain.ini
## Deletes rabbitmq configuration - users will be re-created at startup.
## rabbitmq stores configuration in mnesia tables, which depend on the hostname (can't be changed)
## Can't change container hostname at build time (see https://github.com/docker/docker/issues/1916)
## Other possible way: add a node_name in rabbit-related vhost group_vars
RUN rm -rf /var/lib/rabbitmq/mnesia/

# Ports
EXPOSE 80
EXPOSE 8081
EXPOSE 21
EXPOSE 5672

# Init
ADD ./docker/brain/supervisord.conf /supervisord.conf

ENTRYPOINT ["/usr/local/bin/supervisord", "-c", "/supervisord.conf"]
