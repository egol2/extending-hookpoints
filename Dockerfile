FROM ubuntu:24.04 as Linux-builder

ENV LINUX=/linux 

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install --fix-missing -y git build-essential gcc g++ fakeroot libncurses5-dev libssl-dev ccache dwarves libelf-dev \
 cmake mold \
 libdw-dev libdwarf-dev \
 bpfcc-tools libbpfcc-dev libbpfcc \
 linux-headers-generic \
 libtinfo-dev \
 libstdc++-11-dev libstdc++-12-dev \
 bc \
 flex bison \
 rsync \
 libcap-dev libdisasm-dev binutils-dev unzip \
 pkg-config lsb-release wget software-properties-common gnupg zlib1g llvm \
 qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon xterm attr busybox openssh-server \
 iputils-ping kmod

# Install memcached
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y memcached

# Install memtier_benchmark
# RUN mkdir -p /downloads_memtier && \
#     cd /downloads_memtier && \
#     git clone https://github.com/RedisLabs/memtier_benchmark.git && \
#     cd memtier_benchmark && \
#     autoreconf -ivf && \
#     ./configure --prefix=/usr/local && \
#     make && make install && \
#     rm -rf /downloads_memtier

# nginx
# ENV NGINX_VERSION=1.26.1 \
#     NGINX_RUN=/usr/local/nginx \
#     NGINX_BIN=/usr/local/sbin/nginx \
#     NGINX_CONF=/usr/local/nginx/conf

# Download, extract, configure, and install NGINX
# RUN cd /downloads_nginx \
#     && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
#     && tar xvzf ./nginx-${NGINX_VERSION}.tar.gz \
#     && cd nginx-${NGINX_VERSION} \
#     && ./configure \
#         --sbin-path=/usr/sbin/nginx \
#         --conf-path=/etc/nginx/nginx.conf \
#         --pid-path=/var/run/nginx.pid \
#         --lock-path=/var/lock/nginx.lock \
#         --with-http_ssl_module \
#         --with-pcre \
#     && make \
#     && make install

# Install wrk benchmarking tool
# RUN git clone https://github.com/wg/wrk.git /wrk \
#     && cd /wrk \
#     && make -j $NUM_CPU_CORES \
#     && cp wrk /usr/local/bin/ \
#     && rm -rf /wrk