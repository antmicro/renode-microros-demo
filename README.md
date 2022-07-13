# Renode micro-ROS demo

Copyright (c) 2021-2022 [Antmicro](https://www.antmicro.com)

This repository includes a multi-node micro-ROS demo running in simulation in the [Renode Framework](https://renode.io).

## About the demo

Renode allows for hardware-less development of embedded systems and supports determinism, multiple simulated devices coexisting in one simulation as well as wired and wireless communication protocols, so it's a natural fit for debugging multi-node systems in simulation.

For ease of use, a build script is provided for each step of the build process with their results provided for download as well. Each part of the test is self-contained in  Robot Framework test files (`.robot`) 
and can be launched manually with the instructions provided at the [Run the demos](#run-the-demos) section.

For a manual demonstration, we recommend to run the micro-ROS to ROS 2 test case as it provides clear output if 
everything functions correctly within the system, unlike the micro-ROS to micro-ROS demo 
which relies on reading less structured micro-ROS firmware output to get the confirmation that everything is operational.
In terms of checking the functionality used as such, the two are very closely related.

The repository contains files for testing micro-ROS to micro-ROS and micro-ROS to ROS 2 communication and simple firmware testing. Each scenario is also encapsulated in a Robot test file
that will automate the testing.


## Building and running the demo

### Basic setup
1. Clone the repository:

    ```(bash)
    git clone https://github.com/antmicro/renode-microros-demo.git
    cd renode-microros-demo
    ```

### Build the micro-ROS binary for the STM42F4 Discorvery

Alternatively to this step, you can download the binary
```(bash)
wget -O renode/zephyr.elf https://dl.antmicro.com/projects/renode/zedboard--microros-zephyr.elf-s_1935156-3771522c91ed0f88a761d82a37e245497c142140
```

Build instructions: 
1. In the cloned directory, run a named Docker container based on the `ros:galactic` image:

    ```(bash)
    docker run --rm -v $(pwd):/data --name renode-microros-demo -it ros:galactic
    ```
1. In the Docker container, install the remaining dependencies:

    ```(bash)
    apt-get update
    apt-get install -y python3-pip wget
    ```
1. In the Docker container, go to the directory with the repository and build the solution:

    ```(bash)
    cd /data
    ./build.bash
    ```

### Obtain the Yocto-based linux image(s)

For a quick test, we recommend to download the prebuilt images, however we have included the 
detailed build instructions under the download script.

Please make sure that you are positioned in the root of the repository before running the script.
```(bash)
./download_binaries.sh
```

Build instructions:
1. Select what image you would like to build. The `micro-ros-demo-login` release will provide a shell on the first UART 
and one automatically listening `micro-ros-agent` on the second UART. 
On the other hand, `micro-ros-demo-nologin` is an image used to test micro-ROS to micro-ROS communication.
It has no user input and both UARTs are equipped with an instance of the `micro-ros-agent`.

1. Carefully read the `build_yocto.bash` script. Notice the sudo calls, as this script will require root access.
First one to make sure that docker runs with correct permissions, second one to assign `uid=1000` and `gid=1000`
to the files that will end up on the image and the rest are an effect of that change of permissions. 
Make sure that you select either line 4 OR line 5 (with the other one commented out)
to download the correct set of sources for each image type. By default, the `micro-ros-demo-login` 
image is selected (line 4).

1. Get the `meta-antmicro` layer and build the docker container that will be used to compile the image 
	```(bash)
	git clone https://github.com/antmicro/meta-antmicro
	sudo docker build -t yoctobuilder meta-antmicro
	```
1. Make sure that you are in the root of this repository, and then run
	```(bash)
	./build_yocto.bash
	```

1. To build the Kernel and device tree used in the demo, make sure that you have, as always, positioned yourself
in the root of this repository and run:
    ```(bash)
    ./build_kernel.bash
    ```

### Run the demos
- To run the micro-ROS to micro-ROS communications test, run Renode with the following set of commands. 
	```(bash)
    renode -e "start @renode/zynq.resc; sleep 150; start @renode/first_instance.resc; start @renode/second_instance.resc"
	```
	This will launch the linux machine, wait an appropriate amount of time 
	and then launch two STM32 machines.

    A sign that the demo is working is a line beginning with `Data frame from id...` 
    in the STM32's message log.
    
    Alternatively, you can test the functionality with the robot file:
    ```(bash)
    renode-test tests/multi-node.robot
    ```

- To run the micro-ROS to ROS 2 communications test, setup Renode with just the Linux machine booting. 
    You will see a login screen once it's ready:

    ```(bash)
    renode -e "s @renode/zynq_login.resc"
    ```

    When the login dialog shows, login with `root` and no password, and in the simulated systems' shell run:

    ```(bash)
    . /usr/bin/ros_setup.sh 
    . /usr/share/subscriber/local_setup.sh
    export ROS_DOMAIN_ID=0
    export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
    ros2 run subscriber subscriber_node
    ```

    After running the last command, in the Renode console run the following command:

    ```
    s @renode/first_instance.resc
    ```

    and look for communication on the simulated systems' terminal.
    A `Got from MicroROS id...` line will signify success
    
    Alternatively, you can launch an automated test:

    ```(bash)
    renode-test tests/ros2_communication.robot
    ```