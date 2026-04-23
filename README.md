# Servei Developer

Aquest directori conté els fitxers necessaris per construir la imatge personalitzada per al servei Developer de l'activitat. És un entorn de treball complet integrat dins d'un contenidor Docker.

## Què inclou aquesta imatge?
- **Ubuntu 24.04** com a sistema operatiu base.
- **XFCE4** (entorn d'escriptori lleuger) i **VNC Server** per poder tenir una interfície gràfica.
- **Visual Studio Code** per desenvolupar codi de manera còmoda.
- **Python 3 i Flask** instal·lats per al desenvolupament.
- **psql** (postgresql-client) per poder llançar consultes a la base de dades.
- **Usuari no root**: `devuser` (amb contrasenya `devpass`).

## Ports
- **5901**: Servidor VNC (mapejat al teu localhost:5901).
- **22**: SSH (mapejat al teu localhost:2223).

## Com accedir-hi un cop engegat

### Accés a l'escriptori gràfic (VNC)
Necessites un client VNC al teu ordinador (com VNC Viewer, Remmina, o TigerVNC).
1. Connecta't a `localhost:5901`
2. Utilitza la contrasenya: `devpass`
3. Un cop dins de l'escriptori XFCE, pots obrir el menú i llançar **Visual Studio Code**. Recorda que el volum compartit on tens el codi de Flask està situat a `/workspace`.

### Accés per SSH
Pots accedir-hi des de la terminal de la teva màquina local amb l'usuari desenvolupador:
```bash
ssh devuser@localhost -p 2223
```
(Contrasenya: `devpass`)

### Connexió a la Base de Dades (des del Developer)
Pots comprovar la connectivitat cap al contenidor Postgres obrint una terminal (dins del VNC o via SSH) i executant:
```bash
psql -h postgres -U psqluser -d flaskdb
```
(Et demanarà la contrasenya de postgres que és `psqlpassword`). Això demostrarà que la xarxa "dev" compartida per docker-compose funciona perfectament.
