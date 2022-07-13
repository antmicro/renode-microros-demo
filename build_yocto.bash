mkdir -p  yocto_ws
cd yocto_ws

repo init -u https://github.com/antmicro/meta-antmicro.git -m system-releases/micro-ros-demo-login/manifest.xml; export IMAGE_NAME="zynq_micro_ros_agent_rootfs.img"; export CMD_ARGS=""
#repo init -u https://github.com/antmicro/meta-antmicro.git -m system-releases/micro-ros-demo-nologin/manifest.xml; export IMAGE_NAME="zynq_micro_ros_agents_hush_rootfs.img"; export CMD_ARGS="SERIAL_CONSOLES=\"\""
#Replace the repo init... line with the one commented below it to build the image for micro-ROS to micro-ROS communication 
# with both UARTs reserved for micro-ROS-agents and no user input


repo sync -j`nproc`
pwd
cd sources/
wget https://dl.antmicro.com/projects/renode/zedboard--microros.dtb-s_11991-0b362228a3e8d1a43cf772d4cda5795311a0c9ce
mv zedboard--microros.dtb-s_11991-0b362228a3e8d1a43cf772d4cda5795311a0c9ce zedboard.dtb
cd ..
sudo docker run --rm -v `pwd`:/data -u $(id -u):$(id -u) -it yoctobuilder  bash -c "cd /data; source sources/poky/oe-init-build-env; `echo $CMD_ARGS` PARALLEL_MAKE=\"-j $(nproc)\" BB_NUMBER_THREADS=\"$(nproc)\" MACHINE=\"zedboard-zynq7\" bitbake ros-image-core"
if [ -f build/tmp/deploy/images/**/ros-image-core-galactic-zedboard-zynq7-*rootfs.tar.gz ]
then
	
	sudo mkdir fs
	sudo cp build/tmp/deploy/images/**/ros-image-core-galactic-zedboard-zynq7-*rootfs.tar.gz ./fs
	cd fs
	sudo tar -xvf ./ros-image-core-galactic-zedboard-zynq7-*rootfs.tar.gz
	sudo mv ./ros-image-core-galactic-zedboard-zynq7-*rootfs.tar.gz ../
	cd ..
	truncate --size=200M $IMAGE_NAME
	sudo chown -R root:root ./fs
	sudo mkfs.ext4 -d fs $IMAGE_NAME
	/usr/bin/cp -f $IMAGE_NAME ../renode
	cd ..
fi