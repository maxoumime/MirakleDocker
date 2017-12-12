FROM alpine:3.7
MAINTAINER Maxime Bertheau <maxime.bertheau@gmail.com>

RUN apk --update add openjdk8-jre

ENV ANDROID_HOME=/root/android-sdk
ENV SDK_TOOLS_FILE=sdk-tools-linux-3859397.zip
ENV SDK_MANAGER=$ANDROID_HOME/tools/bin/sdkmanager

RUN wget https://dl.google.com/android/repository/$SDK_TOOLS_FILE
RUN mkdir $ANDROID_HOME
RUN unzip $SDK_TOOLS_FILE -d $ANDROID_HOME

RUN mkdir /root/.android
RUN touch /root/.android/repositories.cfg

RUN yes | $SDK_MANAGER --licenses
RUN $SDK_MANAGER --update

RUN for dependency in $($SDK_MANAGER --list 2>/dev/null | awk '{print $1}' | sed -n -e '/Available/,$p' | egrep '^[[:lower:]]+' | grep -v 'system-images;'); do \
        $SDK_MANAGER "$dependency"; \ 
    done

RUN apk --update add --no-cache openssh bash \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:root" | chpasswd \
  && rm -rf /var/cache/apk/*
RUN sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
RUN sed -ri 's/#HostKey \/etc\/ssh\/ssh_host_key/HostKey \/etc\/ssh\/ssh_host_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_dsa_key/HostKey \/etc\/ssh\/ssh_host_dsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/g' /etc/ssh/sshd_config
RUN sed -ir 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config
RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]

