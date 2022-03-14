[ ! -d ./microros_ws_renode-micro-ros-demo ] && echo run build.bash first && exit 1;

cd microros_ws_renode-micro-ros-demo
source /opt/ros/$ROS_DISTRO/setup.bash
source agent_ws/install/local_setup.bash
source ros2_ws/install/local_setup.bash
cd ..

pkill micro_ros_agent
rm -f ./renode/uart
ros2 run micro_ros_agent micro_ros_agent serial --dev ./renode/uart &
ros2 run subscriber subscriber_node

