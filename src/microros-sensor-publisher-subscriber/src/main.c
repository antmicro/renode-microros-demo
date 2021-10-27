#include <rcl/rcl.h>
#include <rclc/rclc.h>
#include <stdio.h>
#include <zephyr.h>

int main()
{
  // add all initializations: allocator, support and node
  
  rcl_allocator_t def_allocator = rcl_get_default_allocator();
  rclc_support_t support;
  rcl_ret_t return_code = rclc_support_init(&support, argc, argv, &def_allocator);

  rcl_node_t node;
  const char* node_name = "microros_sensor_publisher";
  const char* namespace = "default_namespace";

  rcl_publisher_t publisher;
  const char* topic_name = "microros_sensor_topic";
  const rosdil_message_type_support_t* type_support = 
    ROSDIL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float32);
  

  return_code = rclc_node_init_default(&node, node_name, namespace, &support);
  if(return_code != RCL_RET_OK)
  {
    // TODO: Add some sort of error handling
    return -1;
  }

  return_code = rclc_publisher_init_default(
      &publisher,
      &node,
      &type_suppeort,
      &topic_name
  );
  
  if(return_code != RCL_RET_OK)
  {
    return -2;
  }

  //publish a message
  std_msgs__msg__Float32 msg;
  msg.data = 11.22;
  return_code = rcl_publish(&publisher, &message, NULL);
  while(return_code != RCL_RET_OK)
  {
    // try to publish untill success
    return_code = rcl_publish(&publisher, &message, NULL);
  }

  // cleanup
  
  rcl_publisher_fini(&publisher, &node);
  rcl_node_fini(&node);

  return 0;
}
