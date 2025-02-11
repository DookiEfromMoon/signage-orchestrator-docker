FROM debian:12

# FILES
ADD --chmod=555 systemctl3.py /bin/systemctl
ADD https://github.com/marco-buratto/signage-orchestrator/releases/download/v1.2/signage-orchestrator-backend_1.2-3_all.deb /root/signage-orchestrator-backend_1.2-3_all.deb
ADD https://github.com/marco-buratto/signage-orchestrator/releases/download/v1.2/signage-orchestrator-ui_1.2-1_all.deb /root/signage-orchestrator-ui_1.2-1_all.deb
COPY postinst_patched /root/
COPY orchestrator_patched.service /root/

# PREPARE ENVIRONMENT
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true
ENV RUNLEVEL=1
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d

# INSTALL UPDATES
RUN apt update

# PREPARE ARGUMENTS
ARG TZ_AREA
ARG TZ_CITY

# PREPARE DEBCONF
RUN --mount=type=secret,id=backend_password \
    export BACKEND_PASSWORD=$(cat /run/secrets/backend_password)
RUN echo 'signage-orchestrator-backend signage-orchestrator-backend/admin-password string $BACKEND_PASSWORD' |\
    echo 'tzdata tzdata/Areas select $TZ_AREA' |\
    echo 'tzdata tzdata/Zones/$TZ_AREA select $TZ_CITY' |\
    debconf-set-selections

# INSTALL SIGNAGE ORCHESTRATOR
WORKDIR /root

# PATCHING
RUN mkdir package
RUN dpkg-deb -R ./signage-orchestrator-backend_1.2-3_all.deb package
RUN rm ./package/DEBIAN/postinst && mv ./postinst_patched ./package/DEBIAN/postinst && chmod 755 ./package/DEBIAN/postinst
RUN rm ./package/etc/systemd/system/orchestrator.service && mv ./orchestrator_patched.service ./package/etc/systemd/system/orchestrator.service
RUN dpkg-deb -b package signage-orchestrator-backend_1.2-3_all_patched.deb

RUN apt install -y ./signage-orchestrator-backend_1.2-3_all_patched.deb
RUN apt install -y ./signage-orchestrator-ui_1.2-1_all.deb

CMD /bin/systemctl