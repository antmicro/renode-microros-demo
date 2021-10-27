#include <rcl/rcl.h>
#include <rclc/rclc.h>
#include <stdio.h>
#include <zephyr.h>

int main()
{
  rcl_allocator_t def_allocator = rcl_get_default_allocator();
  rclc_support_t support;
  rcl_ret_t return_code = rclc_support_init(&support, argc, argv, &def_allocator);

  rcl_node_t node;
  const char* node_name = "microros_sensor_publisher";
  const char* namespace = "default_namespace";

  return_code = rclc_node_init_default(&node, node_name, namespace, &support);
  if(return_code != RCL_RET_OK)
  {
    // TODO: Add some sort of error handling
    return -1;
  }
  rcl_node_fini(&node);

  return 0;
}
