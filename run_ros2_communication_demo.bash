[ ! -d ./microros_ws ] && echo run build.bash first && exit 1;

cd microros_ws
source /opt/ros/$ROS_DISTRO/setup.bash
source agent_ws/install/local_setup.bash
source ros2_ws/install/local_setup.bash
cd ..

pkill micro_ros_agent
rm -f ./renode/uart
ros2 run micro_ros_agent micro_ros_agent serial --dev ./renode/uart 2>&1 1>/dev/null&
ros2 run subscriber subscriber_node

