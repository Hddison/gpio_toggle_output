# ============================================================
# mspm0g350x_base.cmake — 工具链 + SDK 配置 (MSPM0G3507)
#
# 使用方式：在 CMakeLists.txt 的 project() 之前 include
#   include(cmake/mspm0g350x_base.cmake)
#   project(my_project C CXX ASM)
#
# 工具链：ARM GNU GCC 15.2
# SDK：   TI MSPM0 SDK 2.10.00.04
# ============================================================

# ---- 交叉编译标识 ----
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)

# ---- 默认构建类型 ----
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

if("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    message(STATUS "Build type: Release (-Ofast)")
    add_compile_options(-Ofast)
elseif("${CMAKE_BUILD_TYPE}" STREQUAL "RelWithDebInfo")
    message(STATUS "Build type: RelWithDebInfo (-Ofast -g)")
    add_compile_options(-Ofast -g)
elseif("${CMAKE_BUILD_TYPE}" STREQUAL "MinSizeRel")
    message(STATUS "Build type: MinSizeRel (-Os)")
    add_compile_options(-Os)
else()
    message(STATUS "Build type: Debug (-Og -g)")
    add_compile_options(-Og -g)
endif()

# ---- ARM GNU GCC 15.2 工具链 ----
set(TOOLCHAIN_ROOT "D:/Developer_tools/ARM_Toolchain/arm-gnu-toolchain-15.2")

if(NOT DEFINED CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER    "${TOOLCHAIN_ROOT}/bin/arm-none-eabi-gcc.exe")
endif()
if(NOT DEFINED CMAKE_CXX_COMPILER)
    set(CMAKE_CXX_COMPILER  "${TOOLCHAIN_ROOT}/bin/arm-none-eabi-g++.exe")
endif()
set(CMAKE_ASM_COMPILER  "${TOOLCHAIN_ROOT}/bin/arm-none-eabi-gcc.exe")
set(CMAKE_AR            "${TOOLCHAIN_ROOT}/bin/arm-none-eabi-ar.exe")
set(CMAKE_OBJCOPY       "${TOOLCHAIN_ROOT}/bin/arm-none-eabi-objcopy.exe")
set(CMAKE_OBJDUMP       "${TOOLCHAIN_ROOT}/bin/arm-none-eabi-objdump.exe")
set(CMAKE_SIZE          "${TOOLCHAIN_ROOT}/bin/arm-none-eabi-size.exe")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ---- TI MSPM0 SDK 路径 ----
set(MSPM0_SDK_PATH "C:/ti/mspm0_sdk_2_10_00_04")
set(SYSCONFIG_PATH "${CMAKE_SOURCE_DIR}/SysConfig")

# ---- Cortex-M0+ 编译选项 ----
add_compile_options(
    -mcpu=cortex-m0plus
    -march=armv6-m
    -mthumb
    -mfloat-abi=soft
    -Wall
    -gstrict-dwarf
    -ffunction-sections
    -fdata-sections
    -fno-common
    -fmessage-length=0
    -fno-exceptions
)

# ---- 汇编文件支持 ----
add_compile_options($<$<COMPILE_LANGUAGE:ASM>:-x$<SEMICOLON>assembler-with-cpp>)

# ---- 头文件路径 ----
include_directories(
    ${MSPM0_SDK_PATH}/source
    ${MSPM0_SDK_PATH}/source/third_party/CMSIS/Core/Include
    ${SYSCONFIG_PATH}
)

# ---- 从 SysConfig 生成文件中读取芯片宏定义 ----
file(STRINGS ${SYSCONFIG_PATH}/device.opt DEVICE_DEFINES)
add_definitions(${DEVICE_DEFINES})

# ---- 库搜索路径（device.lds.genlibs 用相对路径引用 driverlib.a） ----
link_directories(
    ${MSPM0_SDK_PATH}/source
    ${MSPM0_SDK_PATH}/source/ti/driverlib/lib/gcc/m0p/mspm0g1x0x_g3x0x
)

# ---- 链接选项 ----
add_link_options(
    -T${SYSCONFIG_PATH}/device_linker.lds
    -T${SYSCONFIG_PATH}/device.lds.genlibs
    -Wl,-gc-sections,--print-memory-usage,-Map=memory.map
    -mcpu=cortex-m0plus
    -march=armv6-m
    -mthumb
    -static
    -lgcc -lc -lm -lnosys
    --specs=nano.specs
    --specs=nosys.specs
    -nostartfiles
)

# ---- SDK 源文件收集 ----
file(GLOB_RECURSE MSPM0_SDK_SOURCES
    ${MSPM0_SDK_PATH}/source/ti/driverlib/*.c
)
file(GLOB_RECURSE MSPM0_STARTUP
    ${MSPM0_SDK_PATH}/source/ti/devices/msp/m0p/startup_system_files/gcc/startup_mspm0g350x_gcc.c
)
file(GLOB_RECURSE SYSCONFIG_SOURCES
    ${SYSCONFIG_PATH}/*.c
)
