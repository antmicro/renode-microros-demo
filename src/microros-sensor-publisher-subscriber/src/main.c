#include <rcl/rcl.h>
#include <rclc/rclc.h>
#include <stdio.h>
#include <zephyr.h>

int main()
{
  rcl_allocator_t def_allocator = rcl_get_default_allocator();
  rclc_support_t support;
  rcl_ret_t return_code = rclc_support_init(&support, argc, argv, &def_allocator);

  return 0;
}
