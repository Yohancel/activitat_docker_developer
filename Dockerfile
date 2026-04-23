file 
FROM public.ecr.aws/docker/library/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=devuser
ENV PASSWORD=devpass

#Instal·lar dependències del sistema: XFCE4, VNC, eines bàsiques, Python, i PostgreSQL client
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    tigervnc-common \
    wget \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    postgresql-client \
    openssh-server \
    sudo \
    gpg \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

#Instal·lar Visual Studio Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
    rm -f packages.microsoft.gpg && \
    apt-get update && apt-get install -y code && \
    rm -rf /var/lib/apt/lists/* && \
    # Crear wrapper de VS Code amb --no-sandbox (necessari dins contenidors)
    printf '#!/bin/bash\nexec /usr/bin/code --no-sandbox --user-data-dir=/home/devuser/.vscode "$@"\n' \
        > /usr/local/bin/code-no-sandbox && \
    chmod +x /usr/local/bin/code-no-sandbox

#Instal·lar llibreries Python
RUN pip3 install --break-system-packages --ignore-installed Flask gunicorn psycopg2-binary

#Crear un usuari non-root per complir els requisits i configurar sudo
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd && \
    adduser $USER sudo

#Configurar SSH
RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#Configurar VNC per l'usuari devuser
RUN mkdir -p /home/$USER/.vnc && \
    echo $PASSWORD | vncpasswd -f > /home/$USER/.vnc/passwd && \
    chmod 600 /home/$USER/.vnc/passwd && \
    chown -R $USER:$USER /home/$USER/.vnc

#Crear l'script d'inici de XFCE4 per al VNC
RUN echo "#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
startxfce4\n\
" > /home/$USER/.vnc/xstartup && chmod +x /home/$USER/.vnc/xstartup && chown $USER:$USER /home/$USER/.vnc/xstartup

#Copiar i configurar l'script d'arrancada principal
COPY start-vnc.sh /start-vnc.sh
RUN chmod +x /start-vnc.sh

# Crear el workspace
WORKDIR /workspace
RUN chown -R $USER:$USER /workspace

EXPOSE 5901 22

CMD ["/start-vnc.sh"]
