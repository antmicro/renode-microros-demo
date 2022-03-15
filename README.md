# Renode micro-ROS demo

Copyright (c) 2021-2022 [Antmicro](https://www.antmicro.com)

This repository includes a multi-node micro-ROS demo running in simulation in the [Renode Framework](https://renode.io).

## About the demo

Renode allows for hardware-less development of embedded systems and supports determinism, multiple simulated devices coexisting in one simulation as well as wired and wireless communication protocols, so it's a natural fit for debugging multi-node systems in simulation.

For ease of use, a build and run script is provided, automating the process of getting the firmware built and all the tools launched properly for the demo. 

For manual demonstration, we chose to run the micro-ROS to ROS 2 test case as it provides clear output if everything functions correctly within the system, unlike the micro-ROS to micro-ROS demo which relies on reading Renode's UART monitors to get the confirmation that everything is operational.
In terms of checking the functionality used as such, the two are very closely related.

The repository contains files for a micro-ROS to micro-ROS communication setup alongside Robot Framework test files (`.robot`) that will launch the required tests automatically.
Make sure to run the robot files from within the Docker container referenced in the instructions below, and remember to run `build.bash` first to create all the necessary packages.

The `run_ros2_communication_demo.bash` script is responsible for launching the mentioned agent and the ROS 2 subscriber package in the correct order.
There is some sourcing of installations to be done before launching, which is handled by the script.

## Building and running the demo

1. Clone the repository:

    ```(bash)
    git clone https://github.com/antmicro/renode-microros-demo.git
    cd renode-microros-demo
    ```
2. In the cloned directory, run a named Docker container based on the `ros:galactic` image:

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
9. The ROS 2 application in the second container shell and the micro-ROS application running in the first container shell should establish a connection.
   The log in the ROS 2 application should contain:

    `Got from Micro-ROS ID <random device ID>: <received data>`
