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
ADD docker/probe/hosts/irma ./hosts/irma

# Prepare install
## required for virusblokada
RUN mkdir -p /etc/terminfo/d && ln -s /lib/terminfo/d/dumb /etc/terminfo/d/dumb

# Perform install
ADD ansible-requirements.yml ansible-requirements.yml
RUN ansible-galaxy install -r ansible-requirements.yml
WORKDIR /tmp/install/
RUN cd /tmp/install/irma-ansible && ansible-playbook -vvv -i /tmp/install/irma-ansible/hosts/irma /tmp/install/irma-ansible/playbooks/playbook.yml -c local

# Post-install fixes
## Connect the probe to the brain
RUN sed -i 's/brain.irma/irma/' /opt/irma/irma-probe/current/config/probe.ini
RUN sed -i "s/nodaemon = false/nodaemon = true/" /etc/supervisord.conf
RUN chmod 755 /usr/local/uvscan/uvscan
ENV TERM dumb

# Init
ADD ./docker/probe/supervisord.conf /supervisord.conf

ENTRYPOINT ["/usr/local/bin/supervisord", "-c", "/supervisord.conf"]
