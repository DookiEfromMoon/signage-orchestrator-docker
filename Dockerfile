FROM debian:12

# PREPARE ENVIRONMENT
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true

# INSTALL UPDATES
RUN apt update
RUN apt upgrade

# INSTALL DEPENDENCIES
RUN apt install -y wget
RUN RUNLEVEL=1 dpkg --configure -a

# PREPARE ARGUMENTS
ARG TZ_AREA
ARG TZ_CITY

# PREPARE DEBCONF
RUN --mount=type=secret,id=backend_password \
    export BACKEND_PASSWORD=$(cat /run/secrets/backend_password)
RUN echo 'signage-orchestrator-backend signage-orchestrator-backend/admin-password password $BACKEND_PASSWORD' |echo 'tzdata tzdata/Areas select $TZ_AREA' |echo 'tzdata tzdata/Zones/$TZ_AREA select $TZ_CITY' |debconf-set-selections

# INSTALL SIGNAGE ORCHESTRATOR
WORKDIR /root

RUN wget https://github.com/marco-buratto/signage-orchestrator/releases/download/v1.2/signage-orchestrator-backend_1.2-3_all.deb
RUN wget https://github.com/marco-buratto/signage-orchestrator/releases/download/v1.2/signage-orchestrator-ui_1.2-1_all.deb

RUN apt install -y ./signage-orchestrator-backend_1.2-3_all.deb