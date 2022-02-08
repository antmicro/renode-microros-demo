#!/bin/bash

source /opt/ros/$ROS_DISTRO/setup.bash
source /microros_ws/install/local_setup.bash
ros2 run micro_ros_agent micro_ros_agent serial --dev $1/uart1
