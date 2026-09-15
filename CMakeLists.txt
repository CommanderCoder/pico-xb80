# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.13)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Initialise pico_sdk from installed location
# (note this can come from environment, CMake cache etc)

# == DO NOT EDIT THE FOLLOWING LINES for the Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.2.0)
set(toolchainVersion 14_2_Rel1)
set(picotoolVersion 2.2.0-a4)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
set(PICO_BOARD olimex_rp2350_xxl CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

project(ExpansionBus C CXX ASM)

# Build the helper utility used to convert raw binary data into MZF format.
# This must use the host compiler instead of the Pico ARM toolchain so it
# produces a native local executable rather than a Pico ELF.
find_program(HOST_C_COMPILER NAMES cc gcc clang REQUIRED)
set(BIN2MZF_BINARY "${CMAKE_CURRENT_LIST_DIR}/tools/bin2mzf")
add_custom_command(
    OUTPUT "${BIN2MZF_BINARY}"
    COMMAND "${HOST_C_COMPILER}" "${CMAKE_CURRENT_LIST_DIR}/tools/bin2mzf.c" -O2 -o "${BIN2MZF_BINARY}"
    DEPENDS "${CMAKE_CURRENT_LIST_DIR}/tools/bin2mzf.c"
    COMMENT "Building native bin2mzf converter"
    VERBATIM
)
add_custom_target(bin2mzf ALL DEPENDS "${BIN2MZF_BINARY}")

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

# Add executable. Default name is the project name, version 0.1

add_executable(ExpansionBus 
    ExpansionBus.c 
    MZ80K_SD.cpp
    fatfs/ff.c
    fatfs/ffunicode.c
    sdcard/sd_card.cpp
)

pico_set_program_name(ExpansionBus "ExpansionBus")
pico_set_program_version(ExpansionBus "0.1")

# Modify the below lines to enable/disable output over UART/USB
pico_enable_stdio_uart(ExpansionBus 0)
pico_enable_stdio_usb(ExpansionBus 1)

# Generate PIO header from .pio file
pico_generate_pio_header(ExpansionBus ${CMAKE_CURRENT_LIST_DIR}/ExpansionBus.pio)

# Generate ROM data header from assembly file
set(ROM_ASM_SOURCE 
    # "${CMAKE_CURRENT_LIST_DIR}/Z80 Asm/FD_rom.s"
    "${CMAKE_CURRENT_LIST_DIR}/Z80 Asm/FD_rom1.s"
    # "${CMAKE_CURRENT_LIST_DIR}/Z80 Asm/FD_rom2.s"
    )
set(ROM_BIN_OUTPUT ${CMAKE_BINARY_DIR}/FD_rom.bin)
set(ROM_HEADER_OUTPUT ${CMAKE_CURRENT_LIST_DIR}/FD_rom.h)

add_custom_command(
    OUTPUT "${ROM_BIN_OUTPUT}" "${ROM_HEADER_OUTPUT}"
    # 1. Set the working directory properly for all commands
    WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/Z80 Asm"

# 2. Quote paths to tools and outputs to safely handle the space in "Z80 Asm"
    # COMMAND "${CMAKE_CURRENT_LIST_DIR}/tools/sjasmplus" FD_rom1.s --lst --raw=FD_rom1.bin
    # COMMAND "${CMAKE_CURRENT_LIST_DIR}/tools/sjasmplus" FD_rom2.s --lst --raw=FD_rom2.bin
    # COMMAND "${CMAKE_CURRENT_LIST_DIR}/tools/sjasmplus" FD_rom.s --lst --raw=${ROM_BIN_OUTPUT}
    COMMAND "${CMAKE_CURRENT_LIST_DIR}/tools/sjasmplus" FD_rom1.s --lst --raw=${ROM_BIN_OUTPUT}
    COMMAND python3 "${CMAKE_CURRENT_LIST_DIR}/tools/bin2header.py" "${ROM_BIN_OUTPUT}" "${ROM_HEADER_OUTPUT}"
    
# 3. Quote the list variable so CMake expands it correctly
    DEPENDS ${ROM_ASM_SOURCE}
    COMMENT "Generating ROM data header from assembly file"
    VERBATIM
)

add_custom_target(rom_data_header DEPENDS ${ROM_HEADER_OUTPUT})
add_dependencies(ExpansionBus rom_data_header)

# Add the standard library to the build
target_link_libraries(ExpansionBus
        pico_stdlib
        pico_rand
        hardware_pio 
        hardware_dma)

# Add the standard include files to the build
target_include_directories(ExpansionBus PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
        ${CMAKE_CURRENT_LIST_DIR}/sdcard
        ${CMAKE_CURRENT_LIST_DIR}/fatfs
)

pico_add_extra_outputs(ExpansionBus)

