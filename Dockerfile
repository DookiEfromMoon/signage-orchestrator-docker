FROM debian:12

# ARGUMENTS
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true

# INSTALL UPDATES
RUN apt update
RUN apt upgrade

# INSTALL DEPENDENCIES
RUN apt install -y wget

# PREPARE DEBCONF
RUN echo 'signage-orchestrator-backend signage-orchestrator-backend/admin-password password kaka' |debconf-set-selections
RUN echo 'tzdata tzdata/Areas select Europe' |debconf-set-selections
RUN echo 'tzdata tzdata/Zones/Europe select Berlin' |debconf-set-selections

# INSTALL SIGNAGE ORCHESTRATOR
WORKDIR /root

RUN wget https://github.com/marco-buratto/signage-orchestrator/releases/download/v1.2/signage-orchestrator-backend_1.2-3_all.deb
RUN wget https://github.com/marco-buratto/signage-orchestrator/releases/download/v1.2/signage-orchestrator-ui_1.2-1_all.deb

RUN apt install -y ./signage-orchestrator-backend_1.2-3_all.deb