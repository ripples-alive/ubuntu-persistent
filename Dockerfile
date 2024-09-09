FROM busybox:musl AS busybox

FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    btop \
    build-essential \
    cmake \
    cron \
    curl  \
    debian-keyring \
    dnsutils \
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
    tmux \
    trash-cli \
    tzdata \
    wget \
    vim \
    zsh

# Install tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Config timezone
ENV TZ=Asia/Shanghai
RUN ln -nsf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Config locale
RUN locale-gen en_US.UTF-8 && update-locale
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Permit root login for ssh
RUN sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config \
    && sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config

# Prepare template
RUN mkdir /template && rsync -al /etc /home /opt /root /usr /var /template/ && touch /template/.inited
COPY --from=busybox /bin/busybox /template/bin/

# Config entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/template/bin/busybox", "sh", "/entrypoint.sh"]

EXPOSE 22

CMD ["sleep", "infinity"]
