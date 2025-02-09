FROM debian:12
RUN apt update
RUN apt upgrade

# INSTALL DEPENDENCIES
RUN apt install -y wget

# INSTALL SIGNAGE ORCHESTRATOR
RUN cd /root

RUN wget https://github.com/marco-buratto/signage-orchestrator/releases/download/v1.2/signage-orchestrator-backend_1.2-3_all.deb
RUN wget https://github.com/marco-buratto/signage-orchestrator/releases/download/v1.2/signage-orchestrator-ui_1.2-1_all.deb

RUN apt install -y /root/signage-orchestrator-*.deb