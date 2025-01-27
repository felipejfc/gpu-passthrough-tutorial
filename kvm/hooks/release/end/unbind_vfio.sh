#!/bin/bash

source "/etc/libvirt/hooks/kvm.conf"

echo "Unloading VFIO so that amdgpu can bind into the GPU again"
## Unbind gpu from vfio and bind to nvidia
virsh nodedev-reattach pci_0000_${VIRSH_GPU_VIDEO//[:.]/_}
virsh nodedev-reattach pci_0000_${VIRSH_GPU_AUDIO//[:.]/_}
virsh nodedev-reattach pci_0000_${VIRSH_GPU_USB//[:.]/_}
virsh nodedev-reattach pci_0000_${VIRSH_HDA//[:.]/_}

## Unload vfio
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# This step is very important, not only it prevends AMD reset bug and code 49 bug, it also makes it possible for the host to rebind successfully to the GPU
# Uncomment if needed
#echo "Reseting AMD GPU so that we prevent a log of bugs in both host and vm"
#echo "disconnecting amd graphics"
#echo "1" | tee -a /sys/bus/pci/devices/0000\:${VIRSH_GPU_VIDEO}/remove
#echo "disconnecting amd sound counterpart"
#echo "1" | tee -a /sys/bus/pci/devices/0000\:${VIRSH_GPU_AUDIO}/remove
#echo "will go to sleep now for 5 seconds"
#rtcwake -m mem -s 5
#echo "reconnecting amd gpu and sound counterpart"
#echo "1" | tee -a /sys/bus/pci/rescan
#echo "AMD graphics card sucessfully reset"
#
#sleep 5

systemctl start display-manager.service
