#!/bin/bash

taskset --cpu-list 0-15:2 qemu-system-x86_64  \
  -enable-kvm \
  -smp cpus=8,cores=8,sockets=1,threads=1 \
  -cpu host \
  -m 8G \
  -nographic \
  -device virtio-net-pci,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::22222-:22 \
  -drive if=virtio,format=qcow2,file=images/noble-server-cloudimg-amd64-vm1.img \
  -drive if=virtio,media=cdrom,file=seeds/vm1-seed.iso \
  -device vfio-pci,host=0000:01:00.3

# net.ifnames=0 amd_iommu=on iommu=pt vfio_iommu_type1.allow_unsafe_interrupts=1

# taskset --cpu-list 0-15:2 qemu-system-x86_64  \
#   -smp 8 \
#   -cpu host \
#   -m 16G \
#   -nographic \
#   -kernel linux/arch/x86/boot/bzImage \
#   -append "console=ttyS0 root=/dev/vda1 earlyprintk=serial iommu=on net.ifnames=0 pci=nommconf pci=assign-busses pci=nocrs pci=realloc iommu=pt" \
#   -device virtio-net-pci,netdev=net0 \
#   -netdev user,id=net0,hostfwd=tcp::22222-:22 \
#   -drive if=virtio,format=qcow2,file=images/noble-server-cloudimg-amd64-vm1.img \
#   -drive if=virtio,media=cdrom,file=seeds/vm1-seed.iso \
#   -virtfs local,path=linux,mount_tag=host0,security_model=mapped,id=host0 \
#   -device vfio-pci,host=0000:01:00.3 \
#   -enable-kvm