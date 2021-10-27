cmake_minimum_required(VERSION 3.13.1)

include($ENV{ZEPHYR_BASE}/cmake/app/boilerplate.cmake NO_POLICY_SCOPE)
project(microrosapp C CXX)

set(microros_src_dir   ${MICRO_ROS_FIRMWARE_DIR}/zephyr_apps/microros_extensions)
set(microros_build_dir ${MICRO_ROS_FIRMWARE_DIR}/build/microros_extensions)

if(${MICRO_ROS_TRANSPORT} STREQUAL "serial")
  add_compile_definitions(MICRO_ROS_TRANSPORT_SERIAL)
endif()

FILE(GLOB app_sources src/*.c ${microros_src_dir}/microros_transports.c)
include_directories(${microros_src_dir})

target_sources(app PRIVATE ${app_sources})

zephyr_get_include_directories_for_lang_as_string(         C includes)
zephyr_get_system_include_directories_for_lang_as_string(  C system_includes)
zephyr_get_compile_definitions_for_lang_as_string(         C definitions)
zephyr_get_compile_options_for_lang_as_string(             C options)

zephyr_get_include_directories_for_lang_as_string(         CXX includes_cxx)
zephyr_get_system_include_directories_for_lang_as_string(  CXX system_includes_cxx)
zephyr_get_compile_definitions_for_lang_as_string(         CXX definitions_cxx)
zephyr_get_compile_options_for_lang_as_string(             CXX options_cxx)

set(external_project_cflags
  "${includes} ${definitions} ${options} ${system_includes}"
  )

set(external_project_cxxflags
  "${includes_cxx} ${definitions_cxx} ${options_cxx} ${system_includes_cxx}" 
  )

include(ExternalProject)

set(microros_src_dir   ${MICRO_ROS_FIRMWARE_DIR}/zephyr_apps/microros_extensions)
set(microros_build_dir ${MICRO_ROS_FIRMWARE_DIR}/build/microros_extensions)

if(CMAKE_GENERATOR STREQUAL "Unix Makefiles")
set(submake "$(MAKE)")
else()
set(submake "make")
endif()

ExternalProject_Add(
  microroslib_project
  PREFIX   ${microros_build_dir}
  SOURCE_DIR ${microros_src_dir}
  BINARY_DIR ${microros_src_dir}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND
      ${submake}
        PREFIX=${microros_src_dir}
        CC=${CMAKE_C_COMPILER}
        AR=${CMAKE_AR}
        CFLAGS=${external_project_cflags}
        CXX=${CMAKE_CXX_COMPILER}
        CXXFLAGS=${external_project_cxxflags}
        APP_META=$ENV{UROS_APP_FOLDER}/app-colcon.meta

  INSTALL_COMMAND ""
  BUILD_BYPRODUCTS ${MICROROS_LIB_DIR}/libmicroros.a
  )

file(MAKE_DIRECTORY ${MICRO_ROS_FIRMWARE_DIR}/mcu_ws/install)
file(MAKE_DIRECTORY ${MICRO_ROS_FIRMWARE_DIR}/mcu_ws/install/include)

set(MICROROS_LIB_DIR   ${MICRO_ROS_FIRMWARE_DIR}/mcu_ws/install)
set(MICROROS_INCLUDE_DIR ${MICRO_ROS_FIRMWARE_DIR}/mcu_ws/install/include)

add_library(microroslib STATIC IMPORTED GLOBAL)
add_dependencies(
  microroslib
  microroslib_project
  )

add_dependencies(microroslib_project offsets_h)

set_target_properties(microroslib PROPERTIES IMPORTED_LOCATION             ${MICROROS_LIB_DIR}/libmicroros.a)
set_target_properties(microroslib PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${MICROROS_INCLUDE_DIR})

target_link_libraries(app PUBLIC microroslib)