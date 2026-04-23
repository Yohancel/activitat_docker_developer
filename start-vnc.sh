#!/bin/bash

# Arrenquem el servei SSH
service ssh start

# Netegem arxius de bloqueig de X11 per evitar problemes en reiniciar el contenidor
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# Arrenquem el servidor VNC com a usuari "devuser"
su - devuser -c "vncserver :1 -geometry 1280x800 -depth 24 -localhost no"

# Mantenim el contenidor viu llegint els logs de VNC
tail -f /home/devuser/.vnc/*.log
