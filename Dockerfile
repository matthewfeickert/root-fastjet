FROM rootproject/root-ubuntu16:6.12

USER root
WORKDIR /root

SHELL [ "/bin/bash", "-c" ]

RUN curl -O http://fastjet.fr/repo/fastjet-3.3.3.tar.gz && \
    tar zxvf fastjet-3.3.3.tar.gz && \
    cd fastjet-3.3.3/ && \
    mkdir -p /opt/fastjet-install && \
    ./configure --prefix=/opt/fastjet-install && \
    make && \
    make check && \
    make install && \
    cd / && \
    rm -rf /root/*
ENV ROOT_INCLUDE_PATH /opt/fastjet-install/include/
ENV LD_LIBRARY_PATH /opt/fastjet-install/lib/
RUN . /usr/local/bin/thisroot.sh

# Enable tab completion by uncommenting it from /etc/bash.bashrc
# The relevant lines are those below the phrase "enable bash completion in interactive shells"
RUN export SED_RANGE="$(($(sed -n '\|enable bash completion in interactive shells|=' /etc/bash.bashrc)+1)),$(($(sed -n '\|enable bash completion in interactive shells|=' /etc/bash.bashrc)+7))" && \
    sed -i -e "${SED_RANGE}"' s/^#//' /etc/bash.bashrc && \
    unset SED_RANGE

# Create user "docker" with sudo powers
RUN useradd -m docker && \
    usermod -aG sudo docker && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    cp /root/.bashrc /home/docker/ && \
    mkdir /home/docker/data && \
    chown -R --from=root docker /home/docker

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /home/docker/data
ENV HOME /home/docker
ENV USER docker
USER docker
ENV PATH /home/docker/.local/bin:$PATH
# Avoid first use of sudo warning. c.f. https://askubuntu.com/a/22614/781671
RUN touch $HOME/.sudo_as_admin_successful

CMD [ "/bin/bash" ]
