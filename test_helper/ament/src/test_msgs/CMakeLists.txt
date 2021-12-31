cmake_minimum_required(VERSION 3.5)

project(test_msgs)

# Default to C++14
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif()
if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(test_interface_files REQUIRED)
find_package(rosidl_default_generators REQUIRED)


rosidl_generate_interfaces(${PROJECT_NAME}
  ${test_interface_files_MSG_FILES}
  ${test_interface_files_SRV_FILES}
  ${test_interface_files_ACTION_FILES}
)

ament_export_dependencies(rosidl_default_runtime)

ament_package()