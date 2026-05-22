# ============================================================
# CMakeLists.txt — GPIO Toggle Output (MSPM0G3507)
#
# 编译:
#   cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -GNinja -Bbuild
#   cmake --build build
#
# Change Log:
#   2025-05-22  初始版本，基于 mspm0-cmake-freertos-template 模板简化
# ============================================================

cmake_minimum_required(VERSION 3.22)

# 加载工具链 + SDK 配置（必须在 project() 之前）
include(cmake/mspm0g350x_base.cmake)

# 定义工程
project(gpio_toggle_output C CXX ASM)

# ---- 用户源码 ----
file(GLOB USER_SOURCES *.c)

# ---- 最终可执行目标 ----
add_executable(${CMAKE_PROJECT_NAME}.elf
    ${USER_SOURCES}
    ${SYSCONFIG_SOURCES}
    ${MSPM0_SDK_SOURCES}
    ${MSPM0_STARTUP}
)
