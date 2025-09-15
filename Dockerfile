# Copyright (c) Forge
# SPDX-License-Identifier: MPL-2.0

FROM docker.io/library/fedora:42

RUN dnf5 -y upgrade
RUN dnf5 -y install systemd

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);

RUN rm -f /lib/systemd/system/multi-user.target.wants/*
RUN rm -f /etc/systemd/system/*.wants/*
RUN rm -f /lib/systemd/system/local-fs.target.wants/*
RUN rm -f /lib/systemd/system/sockets.target.wants/*udev*
RUN rm -f /lib/systemd/system/sockets.target.wants/*initctl*
RUN rm -f /lib/systemd/system/basic.target.wants/*
RUN rm -f /lib/systemd/system/anaconda.target.wants/*

RUN ln -s /usr/lib/systemd/system/systemd-user-sessions.service /etc/systemd/system/multi-user.target.wants/systemd-user-sessions.service

RUN dnf5 -y install \
        sudo \
        which \
        python3-libdnf \
        openssh-server

RUN dnf clean all

RUN useradd -m forge
RUN echo "forge ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "forge:forge" | chpasswd

RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

RUN chmod 0400 /etc/shadow

RUN mkdir -p /home/forge/.ssh
RUN chmod 700 /home/forge/.ssh
RUN chown forge:forge /home/forge/.ssh

COPY ssh/authorized_keys /home/forge/.ssh/authorized_keys
RUN chmod 600 /home/forge/.ssh/authorized_keys
RUN chown forge:forge /home/forge/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/sbin/init"]
