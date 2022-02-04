#include <rcl/rcl.h>
#include <rclc/rclc.h>
#include <rclc/executor.h>

#include <std_msgs/msg/header.h>
#include <std_msgs/msg/float64.h>
#include <std_msgs/msg/float64_multi_array.h>
#include <std_msgs/msg/int64_multi_array.h>
#include <std_msgs/msg/multi_array_layout.h>

#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <random/rand32.h>

#include <rmw_microros/rmw_microros.h>
#include <microros_transports.h>

#include <micro_ros_utilities/type_utilities.h>
#include <micro_ros_utilities/string_utilities.h>

#include <zephyr.h>
#include <device.h>

#define CHAR_LABEL_BUF_SIZE 10

unsigned long long dev_id=0;
std_msgs__msg__Float64MultiArray msg, incoming;
rcl_publisher_t publisher;

void subscriber_callback(const void * m)
{
	const std_msgs__msg__Float64MultiArray * rcv = (const std_msgs__msg__Float64MultiArray *) m;
	if(rcv->data.data[0] != *((double*) &dev_id))
		printk("Data frame from id %llx: %llx\n", *((unsigned long long*)&(rcv->data.data[0])), *((unsigned long long*)&(rcv->data.data[1])));
	else
		printk("Got my own or corrupted message\n");
}

void publisher_timer_callback()
{
	msg.data.data[0] = *((double*) &dev_id);
	msg.data.data[1] = (double) 11.22;
	rcl_ret_t return_code = RCL_RET_OK + 1;
	while(return_code != RCL_RET_OK)
	{
		return_code = rcl_publish(&publisher, &msg, NULL);
		printk("Sending message ");
		printk("id %llx, data %llx\n",  *((unsigned long long*)&(msg.data.data[0])), *((unsigned long long*)&(msg.data.data[1])));
	}
}

void allocate_float64multiarray_msg_to_spec(std_msgs__msg__Float64MultiArray* m)
{
	m->data.capacity = 2;
	m->data.data = (double*)malloc(sizeof(double)*2);
	m->data.size = 2;
	m->layout.dim.capacity = 2;
	m->layout.dim.size = 1;
	m->layout.dim.data = (std_msgs__msg__MultiArrayDimension*)malloc(
		2*sizeof(std_msgs__msg__MultiArrayDimension)
	);
	for(char i = 0; i < msg.layout.dim.capacity; i++)
	{
		m->layout.dim.data[i].label.capacity = CHAR_LABEL_BUF_SIZE;
		m->layout.dim.data[i].label.size = 0;
		m->layout.dim.data[i].label.data = (char*)malloc(CHAR_LABEL_BUF_SIZE * sizeof(char));
	}
	return;
}

int main()
{
	rcl_allocator_t def_allocator = rcl_get_default_allocator();
	// Device ID generation from PyDev
	dev_id = (unsigned long long)*((unsigned*)(0x70006080));
	printk("Device ID: %llx\n", *((unsigned long long*)(&dev_id)));
	allocate_float64multiarray_msg_to_spec(&msg);
	allocate_float64multiarray_msg_to_spec(&incoming);
	// add all initializations: allocator, support and node
	rmw_uros_set_custom_transport(
		MICRO_ROS_FRAMING_REQUIRED,
		&default_params,
		zephyr_transport_open,
		zephyr_transport_close,
		zephyr_transport_write,
		zephyr_transport_read
	);
	
	rclc_support_t support;
	rcl_ret_t return_code = rclc_support_init(&support, 0, NULL, &def_allocator);

	rcl_timer_t timer;
	rclc_timer_init_default(&timer, &support, RCL_MS_TO_NS(2000), publisher_timer_callback);

	rcl_node_t node;
	const char* node_name = "microros_sensor_publisher";
	const char* namespace = "default_namespace";

	const char* topic_name = "microros_sensor_topic";

	rcl_subscription_t subscriber;
	
	return_code = rclc_node_init_default(&node, node_name, namespace, &support);
	if(return_code != RCL_RET_OK)
		return return_code;

	return_code = rclc_publisher_init_default(
			&publisher,
			&node,
			ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float64MultiArray),
			topic_name
	);
	
	if(return_code != RCL_RET_OK)
		return return_code;

	rclc_subscription_init_best_effort(
		&subscriber,
		&node,
		ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Float64MultiArray),
		topic_name
	);


	rclc_executor_t executor;
	
	rclc_executor_init(
		&executor,
		&support.context,
		2,
		&def_allocator
	);
	rclc_executor_add_timer(&executor, &timer);
	rclc_executor_add_subscription(
		&executor,
		&subscriber,
		&incoming,
		&subscriber_callback,
		ON_NEW_DATA
	);
	while(1)
	{
		rclc_executor_spin_some(&executor, RCL_MS_TO_NS(100));
		usleep(100000);
	}

	rcl_publisher_fini(&publisher, &node);
	rcl_node_fini(&node);
	return 0;
}
