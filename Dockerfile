FROM busybox:musl AS busybox

FROM phusion/baseimage:noble-1.0.0

# Install dependencies
RUN install_clean \
    btop \
    build-essential \
    cmake \
    cron \
    curl \
    debian-keyring \
    dnsutils \
    file \
    g++ \
    gcc \
    git \
    htop \
    httpie \
    inetutils-traceroute \
    iputils-ping \
    locales \
    locate \
    lsof \
    make \
    man \
    mtr \
    net-tools \
    netcat-openbsd \
    netcat-traditional \
    openssh-server \
    rsync \
    silversearcher-ag \
    socat \
    software-properties-common \
    sudo \
    tmux \
    trash-cli \
    tzdata \
    vim \
    wget \
    zsh

# Install tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Config timezone
ENV TZ=Asia/Shanghai

# Enable sshd
RUN rm -f /etc/service/sshd/down

# Add tailscale service
COPY service/tailscale /etc/service/tailscale

# Set sudo without password
RUN sed -i 's/\(^%sudo.*\)ALL$/\1NOPASSWD:ALL/' /etc/sudoers

# Prepare template
RUN mkdir /template && rsync -al /etc /home /opt /root /usr /var /template/
COPY --from=busybox /bin/busybox /template/usr/bin/

# Config entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/template/usr/bin/busybox", "sh", "/entrypoint.sh"]

EXPOSE 22

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
