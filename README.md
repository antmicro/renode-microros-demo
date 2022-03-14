# Renode micro-ROS demo

Copyright (c) 2021-2022 [Antmicro](https://www.antmicro.com)

This repository demonstrates the ability for the Renode Framework to run a micro-ROS based firmware.


## About the demo

Renode allows for hardware-less development of embedded systems. We wanted to test if developing micro-ROS solutions using this framework is possible, so we have developed a test to check if a test firmware will run and check compatibility between micro-ROS running in Renode and ROS 2 on the host system. 

Using a UART file we redirect the simulated UART to the host and attach the micro-ROS agent (supplied with ROS 2) to it as if it was a normal device file. We have for the ease of use added a build and run script that will automate the process of getting the firmware built and all the tools launched properly for the demo. 

We chose for the manual demonstration to run the micro-ROS to ROS 2 test case as it provides clear output if everything functions correctly within the system, unlike the micro-ROS to micro-ROS demo which relies on reading Renode's UART monitors to get the confirmation that everything is operational. In terms of checking the functionality itself, the two are very closely related in terms of used functionality, making the ROS 2 tests the perfect candidate for manual testing.

The communication between the ROS 2 environment and micro-ROS is handled by the micro_ros_agent package, that the script builds and runs when needed. The messages are received from the topic via a ROS 2 Subscriber package that prints them to the terminal. There are supplied files for a micro-ROS to micro-ROS communication setup alongside `.robot` Robot Framework test files that will launch the required tests automatically. Make sure to run the robot files from within the Docker container referenced in the instructions below, as well as run `build.bash` first to create all the necessary packages.

The `run_ros2_communication_demo.bash` script is responsible for launching the mentioned agent and the ROS 2 subscriber package in the correct order. There is some sourcing of installations to be done before launching, which is handled by the script.


## Building and running the demo

### Download and build the demo packages and dependencies
1. Clone the repository:

    ```(bash)
    git clone https://github.com/antmicro/renode-microros-demo.git
    cd renode-microros-demo
    ```
2. In the cloned directory, run the named Docker container based on the `ros:galactic` image:

    ```(bash)
    docker run --rm -v $(pwd):/data --name renode-microros-demo -it ros:galactic
    ```
3. In the Docker container, install the remaining dependencies:

    ```(bash)
    apt-get update
    apt-get install -y python3-pip wget
    ```
4. Get Renode in the Docker container - the most convenient way is to get the latest portable release, extract it and add the executable to the PATH variable
    ```(bash)
    wget https://builds.renode.io/renode-latest.linux-portable.tar. gz
    tar -xvf renode-latest.linux-portable.tar.gz
    mv renode_* renode_portable
    export PATH=/renode_portable:$PATH

    ```
5. In the Docker container, go to the directory with the repository and build the solution:

    ```(bash)
    cd /data
    ./build.bash
    ```
### Run the demo and verify that messages are being received
6. In another terminal, connect to the running container using:

    ```(bash)
    docker exec -it renode-microros-demo /bin/bash
    ```
7. In the second container shell, run the ROS 2 instance fetching data from the simulated microcontroller:

    ```(bash)
    cd /data
    ./run_ros2_communication_demo.bash
    ```
8. In the first container shell, run Renode simulation of the machine running micro-ROS publisher-subscriber:

    ```(bash)
    renode -e "s @./renode/first_instance.resc"
    ```
9. The ROS 2 application in the second container shell and the micro-ROS application running in the first container shell should establish a connection. The log in the ROS 2 application should contain:

    `Got from Micro-ROS ID <random device ID>: <received data>`
