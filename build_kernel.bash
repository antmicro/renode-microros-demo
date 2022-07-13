#!/bin/bash
if [ ! -d yocto_ws ] && [ ! -d kernel_workspace ]
then
	mkdir kernel_workspace
	cd kernel_workspace
	repo init -u https://github.com/antmicro/meta-antmicro.git -m system-releases/micro-ros-demo-login/manifest.xml
	repo sync -j`nproc`
	cd kernel_ws

elif [ -d yocto_ws ]
then
	cd yocto_ws/kernel_ws
else
	cd kernel_workspace/kernel_ws
fi
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j `nproc` virtio_zynq_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j `nproc` vmlinux
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j `nproc` dtbs
cp vmlinux ../
cp arch/arm/boot/dts/zynq-zed-virtio.dtb ../
cd ..
mv vmlinux zynq-virtio-vmlinux
mv zynq-zed-virtio.dtb zed.dtb
mv zynq-virtio-vmlinux ../renode
mv zed.dtb ../renode
cd ..
