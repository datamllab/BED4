################################################################################
 # Copyright (C) Maxim Integrated Products, Inc., All Rights Reserved.
 #
 # Permission is hereby granted, free of charge, to any person obtaining a
 # copy of this software and associated documentation files (the "Software"),
 # to deal in the Software without restriction, including without limitation
 # the rights to use, copy, modify, merge, publish, distribute, sublicense,
 # and/or sell copies of the Software, and to permit persons to whom the
 # Software is furnished to do so, subject to the following conditions:
 #
 # The above copyright notice and this permission notice shall be included
 # in all copies or substantial portions of the Software.
 #
 # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 # OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 # MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 # IN NO EVENT SHALL MAXIM INTEGRATED BE LIABLE FOR ANY CLAIM, DAMAGES
 # OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 # ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 # OTHER DEALINGS IN THE SOFTWARE.
 #
 # Except as contained in this notice, the name of Maxim Integrated
 # Products, Inc. shall not be used except as stated in the Maxim Integrated
 # Products, Inc. Branding Policy.
 #
 # The mere transfer of this software does not imply any licenses
 # of trade secrets, proprietary technology, copyrights, patents,
 # trademarks, maskwork rights, or any other form of intellectual
 # property whatsoever. Maxim Integrated Products, Inc. retains all
 # ownership rights.
 #
 #
 ###############################################################################

# This is the name of the build output file
CAMERA=OV7692
ifeq "$(PROJECT)" ""
PROJECT=max78000
endif

# Specify the target processor
ifeq "$(TARGET)" ""
TARGET=MAX78000
endif

# Create Target name variables
TARGET_UC:=$(shell echo $(TARGET) | tr a-z A-Z)
TARGET_LC:=$(shell echo $(TARGET) | tr A-Z a-z)

# Select 'GCC' or 'IAR' compiler
COMPILER=GCC

# Specify the board used
ifeq "$(BOARD)" ""
BOARD=EvKit_V1
#BOARD=FTHR_RevA
endif

# This is the path to the CMSIS root directory
LIBS_DIR=../../../../Libraries
CMSIS_ROOT=$(LIBS_DIR)/CMSIS
CNN_ROOT=../../../../Examples/$(TARGET)/CNN

#Use this for other library make files so they are all based off the same as root as the project
export CMSIS_ROOT

# Source files for this test (add path to VPATH below)
SRCS  = main.c
ifeq "$(BOARD)" "EvKit_V1"
SRCS += TFT/evkit/resources/all_imgs.c
endif
ifeq "$(BOARD)" "FTHR_RevA"
SRCS += TFT/fthr/logo_rg565.c
SRCS += TFT/fthr/SansSerif16x16.c
SRCS += TFT/fthr/SansSerif19x19.c
endif
SRCS += src/utils.c
SRCS += src/state.c
SRCS += src/state_home.c
SRCS += src/state_faceID.c
SRCS += src/cnn.c
SRCS += src/embedding_process.c
SRCS += src/sigmoid.c

# Where to find source files for this test
VPATH=.
ifeq "$(BOARD)" "EvKit_V1"
VPATH += ./TFT/evkit/resources
endif
ifeq "$(BOARD)" "FTHR_RevA"
VPATH += TFT/fthr/
endif
VPATH += $(CMSIS_ROOT)/Device/Maxim/$(TARGET_UC)/Source
VPATH += $(CNN_ROOT)/Common
VPATH += ./src

# Where to find header files for this test
IPATH = .
ifeq "$(BOARD)" "EvKit_V1"
IPATH += ./TFT/evkit/resources
endif
IPATH += ./include
IPATH += $(CNN_ROOT)/Common

# Enable assertion checking for development
PROJ_CFLAGS+=-DMXC_ASSERT_ENABLE

PROJ_CFLAGS+=-DARM_MATH_CM4

ifeq "$(BOARD)" "EvKit_V1"
PROJ_CFLAGS+=-DROTATE_SCREEN=1
PROJ_CFLAGS+=-DTFT_ENABLE
PROJ_CFLAGS+=-DTS_ENABLE
endif

ifeq "$(BOARD)" "FTHR_RevA"
# Only enable if 2.4" TFT is connected to Feather
#PROJ_CFLAGS+=-DTFT_ENABLE
endif

# Enable all warnings
PROJ_CFLAGS+=-Wall

# Specify the target revision to override default
# "A2" in ASCII
# TARGET_REV=0x4132

# Use this variables to specify and alternate tool path
#TOOL_DIR=/opt/gcc-arm-none-eabi-4_8-2013q4/bin

# Use these variables to add project specific tool options
#PROJ_CFLAGS+=-D__FPU_PRESENT -DKINTEX_EMU
#PROJ_LDFLAGS+=--specs=nano.specs

# Point this variable to a startup file to override the default file
#STARTUPFILE=start.S

# Set MXC_OPTIMIZE to override the default optimization level
MXC_OPTIMIZE_CFLAGS=-O2

# Point this variable to a linker file to override the default file
LINKER=$(TARGET_LC).ld
LINKERFILE=$(CMSIS_ROOT)/Device/Maxim/$(TARGET_UC)/Source/GCC/$(LINKER)

# Run bitmap converter to produce tft resource header and resource file
#$(shell $(LIBS_DIR)/Tools/BitmapConverter/maxim_bitmap_converter ./resources)

################################################################################
# Include external library makefiles here

# Include the BSP
BOARD_DIR=$(LIBS_DIR)/Boards/$(TARGET_UC)/$(BOARD)
include $(BOARD_DIR)/board.mk

# Include the peripheral driver
PERIPH_DRIVER_DIR=$(LIBS_DIR)/PeriphDrivers
include $(PERIPH_DRIVER_DIR)/periphdriver.mk
export PERIPH_DRIVER_DIR

################################################################################
# Include the rules for building for this target. All other makefiles should be
# included before this one.
include $(CMSIS_ROOT)/Device/Maxim/$(TARGET_UC)/Source/$(COMPILER)/$(TARGET_LC).mk

all:
# 	arm-none-eabi-objcopy $(BUILD_DIR)/$(PROJECT).elf -R .sig -O binary $(BUILD_DIR)/$(PROJECT).bin
# 	$(CA_SIGN_BUILD) $(BUILD_DIR)/$(PROJECT).bin $(TEST_KEY)
# 	arm-none-eabi-objcopy  $(BUILD_DIR)/$(PROJECT).elf --update-section .sig=$(BUILD_DIR)/$(PROJECT).bin.sig

libclean: 
	$(MAKE)  -f ${PERIPH_DRIVER_DIR}/periphdriver.mk clean.periph
	
# The rule to clean out all the build products.
distclean: clean libclean

sla: all

#	arm-none-eabi-objcopy $(BUILD_DIR)/$(PROJECT).elf -O binary $(BUILD_DIR)/$(PROJECT).sbin
#	$(BUILD_SESSION) $(BUILD_DIR)/$(PROJECT).sbin scp_packets $(TEST_KEY)

version:
	$(CC) --version
