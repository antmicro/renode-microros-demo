#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/float64.hpp"
using std::placeholders::_1;

class Subscriber : public rclcpp::Node
{
  public:
    Subscriber() : Node("Subscriber")
    {
      subscription_ = this->create_subscription<std_msgs::msg::Float64>(
      "default_namespace/microros_sensor_topic", 10, std::bind(&Subscriber::topic_callback, this, _1));
    }
  private:
    void topic_callback(const std_msgs::msg::Float64::SharedPtr msg) const
    {
      printf(
        "Got from MicroROS: '%lf'\n",
        msg->data
      );
    }
    rclcpp::Subscription<std_msgs::msg::Float64>::SharedPtr subscription_;
};

int main(int argc, char * argv[])
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<Subscriber>());
  rclcpp::shutdown();
  return 0;
}
