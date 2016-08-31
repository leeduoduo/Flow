############################################################################
#
#   Copyright (c) 2015 PX4 Development Team. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
# 3. Neither the name PX4 nor the names of its contributors may be
#    used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
#############################################################################
set(PX4FLOW_SRC
	
	led.c
	utils.c
	settings.c
	communication.c
	flow.c
	dcmi.c
	mt9v034.c
	gyro.c
	usart.c
	sonar.c
	debug.c
	usb_bsp.c
	usbd_cdc_vcp.c
	usbd_desc.c
	usbd_usr.c
	i2c.c
	reset.c
	sonar_mode_filter.c
	system_stm32f4xx.c
	stm32f4xx_it.c
	main.c
	)
add_executable(px4flow	${PX4FLOW_SRC})
add_dependencies(px4flow ${module_libraries} prebuild_targets)
target_link_libraries(px4flow ${module_libraries} nosys m)
set_target_properties(px4flow PROPERTIES
		LINK_FLAGS "-T${CMAKE_BINARY_DIR}/baremetal-configs/baremetal-export/build/ld.script")

add_custom_command(OUTPUT px4flow.px4
	COMMAND ${OBJCOPY} --output-format=binary px4flow px4flow.bin
	COMMAND python -u ${CMAKE_SOURCE_DIR}/Tools/px_mkfw.py --board_id 6 > px4flow_prototype.px4
	COMMAND python -u ${CMAKE_SOURCE_DIR}/Tools/px_mkfw.py --prototype px4flow_prototype.px4 --image px4flow.bin > px4flow.px4
	DEPENDS px4flow
	)
add_custom_target(firmware_px4flow ALL DEPENDS px4flow.px4)

set(SERIAL_PORTS "/dev/ttyACM5,/dev/ttyACM4,/dev/ttyACM3,/dev/ttyACM2,/dev/ttyACM1,/dev/ttyACM0")


add_custom_target(upload-usb
    COMMAND echo "Attempting to flash PX4FLOW board via USB ${SERIAL_PORTS}"
    COMMAND python -u ${CMAKE_SOURCE_DIR}/Tools/px_uploader.py px4flow.px4 --baud 921600 --port ${SERIAL_PORTS}
    DEPENDS px4flow.px4)


# vim: set noet ft=cmake fenc=utf-8 ff=unix : 
