BASE_PROJ ?= $(shell pwd)
LINUX ?= ${BASE_PROJ}/linux
SSH_PORT ?= "59822"
NET_PORT ?= "59823"
GDB_PORT ?= "1934"
DOCKER_TAG ?= "runtime-dev-egor"
.ALWAYS:

all: vmlinux 

docker: .ALWAYS
	docker buildx build --network=host --progress=plain -t ${DOCKER_TAG} .

qemu-run: 
	docker run --privileged --rm \
	--device=/dev/vfio:/dev/vfio \
	--device=/dev/kvm:/dev/kvm --device=/dev/net/tun:/dev/net/tun \
	--network=host \
	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
	-w /linux \
	-it ${DOCKER_TAG}:latest \
	/linux-dev-env/q-script/yifei-q -s

# qemu-run: 
# 	docker run --privileged --rm \
# 	--device=/dev/vfio:/dev/vfio \
# 	--device=/dev/kvm:/dev/kvm --device=/dev/net/tun:/dev/net/tun \
#     --network host \
# 	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
# 	-w /linux \
# 	-it ${DOCKER_TAG}:latest \
# 	taskset --cpu-list 0-15:2 qemu-system-x86_64  \
# 	-enable-kvm \
# 	-smp cpus=8,cores=8,sockets=1,threads=1 \
# 	-cpu host \
# 	-m 8G \
# 	-nographic \
# 	-device virtio-net-pci,netdev=net0 \
# 	-netdev user,id=net0,hostfwd=tcp::22222-:22 \
# 	-device vfio-pci,host=0000:01:00.3
# 	-kernel arch/x86/boot/bzImage \
# 	-append "console=ttyS0 rdinit=/bin/bash"

# qemu-run: 
# 	docker run --privileged --rm \
# 	--device=/dev/kvm:/dev/kvm \
# 	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
# 	-w /linux \
# 	-p 127.0.0.1:${SSH_PORT}:52222 \
# 	-p 127.0.0.1:${NET_PORT}:52223 \
# 	-p 127.0.0.1:${GDB_PORT}:1234 \
# 	-it ${DOCKER_TAG}:latest \
# 	/linux-dev-env/q-script/yifei-q -s

# connect running qemu by ssh
qemu-ssh:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -t root@127.0.0.1 -p ${SSH_PORT}

vmlinux: 
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER_TAG}  make -j`nproc` bzImage 

headers-install: 
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER_TAG}  make -j`nproc` headers_install 

modules-install: 
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER_TAG}  make -j`nproc` modules
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER_TAG}  make -j`nproc` modules_install

kernel:
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER_TAG}  make -j`nproc` 

linux-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux ${DOCKER_TAG} make distclean

enter-docker:
	docker run --rm -v ${BASE_PROJ}:/linux-dev-env -w /linux-dev-env -it ${DOCKER_TAG} /bin/bash

enter-docker-fullvm:
	docker run --privileged --rm \
	--device=/dev/vfio:/dev/vfio \
	--device=/dev/kvm:/dev/kvm --device=/dev/net/tun:/dev/net/tun \
    --network host \
	-p 127.0.0.1:${SSH_PORT}:52222 \
	-p 127.0.0.1:${NET_PORT}:52223 \
	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
	-w /linux-dev-env \
	-it ${DOCKER_TAG}:latest /bin/bash

buzzer-qemu-run:
	docker run --privileged --rm \
	--device=/dev/vfio:/dev/vfio \
	--device=/dev/kvm:/dev/kvm --device=/dev/net/tun:/dev/net/tun \
	--network="host" \
	-v ${BASE_PROJ}:/linux-dev-env -v ${LINUX}:/linux \
	-w /linux-dev-env \
	-it ${DOCKER_TAG}:latest \
	qemu-system-x86_64 \
			-m 20G \
			-smp 8 \
			-cpu host \
			-kernel linux/arch/x86/boot/bzImage \
			-append "console=ttyS0 root=/dev/sda nokaslr earlyprintk=serial net.ifnames=0" \
			-drive file=buzzer-image/bullseye.img,format=raw \
			-device virtio-net-pci,netdev=net0 \
			-netdev user,id=net0,hostfwd=tcp::22222-:22 \
			-device vfio-pci,host=0000:01:00.3 \
			-enable-kvm \
			-nographic \
			-pidfile vm.pid \
			2>&1 | tee vm.log

buzzer-qemu-ssh:
	ssh -i buzzer-image/bullseye.id_rsa -p 10022 root@localhost

libbpf:
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/lib/bpf runtime-dev make -j`nproc`

libbpf-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/lib/bpf runtime-dev make clean -j`nproc`

bpftool:
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/bpf/bpftool runtime-dev make -j`nproc`

bpftool-clean:
	docker run --rm -v ${LINUX}:/linux -w /linux/tools/bpf/bpftool runtime-dev make clean -j`nproc`
