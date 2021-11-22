#include <rcl/rcl.h>
#include <rclc/rclc.h>
#include <rclc/executor.h>

#include <std_msgs/msg/header.h>
#include <std_msgs/msg/float64.h>

#include <stdio.h>
#include <unistd.h>
#include <time.h>

#include <rmw_microros/rmw_microros.h>
#include <microros_transports.h>

#include <zephyr.h>

int main()
{
  // add all initializations: allocator, support and node
  rmw_uros_set_custom_transport(
    MICRO_ROS_FRAMING_REQUIRED,
    &default_params,
    zephyr_transport_open,
    zephyr_transport_close,
    zephyr_transport_write,
    zephyr_transport_read
	);
  
  rcl_allocator_t def_allocator = rcl_get_default_allocator();
  rclc_support_t support;
  rcl_ret_t return_code = rclc_support_init(&support, 0, NULL, &def_allocator);

  rcl_node_t node;
  const char* node_name = "microros_sensor_publisher";
  const char* namespace = "default_namespace";

  rcl_publisher_t publisher;
  const char* topic_name = "microros_sensor_topic";

  return_code = rclc_node_init_default(&node, node_name, namespace, &support);
  if(return_code != RCL_RET_OK)
  {
    // TODO: Add some sort of error handling
    return -1;
  }

  return_code = rclc_publisher_init_default(
      &publisher,
      &node,
      ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float64),
      topic_name
  );
  
  if(return_code != RCL_RET_OK)
  {
    return -2;
  }

  //publish a message
  std_msgs__msg__Float64* msg = (std_msgs__msg__Float64*)malloc(sizeof(std_msgs__msg__Float64)); 
  (*msg).data = 11.22;
  return_code = rcl_publish(&publisher, msg, NULL);
  for(int i=0;i<1000;i++)
  {
    while(return_code != RCL_RET_OK)
    {
      // try to publish untill success
      return_code = rcl_publish(&publisher, msg, NULL);
    }
        
    (*msg).data = 11.22;
    usleep(1000000);
    return_code += 1; // For testing, so that the while() executes again
  }
  // cleanup
  rcl_publisher_fini(&publisher, &node);
  rcl_node_fini(&node);
  free(msg);
  return 0;
}
