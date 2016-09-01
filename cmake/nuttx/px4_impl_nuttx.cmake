############################################################################
#
# Copyright (c) 2015 PX4 Development Team. All rights reserved.
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
############################################################################

#=============================================================================
#
#	Defined functions in this file
#
# 	OS Specific Functions
#
#		* px4_nuttx_add_firmware
#		* px4_nuttx_generate_builtin_commands
#		* px4_nuttx_add_export
#		* px4_nuttx_add_romfs
#
# 	Required OS Inteface Functions
#
# 		* px4_os_add_flags
#		* px4_os_prebuild_targets
#

include(common/px4_base)




#=============================================================================
#
#	px4_nuttx_add_export
#
#	This function generates a nuttx export.
#
#	Usage:
#		px4_nuttx_add_export(
#			OUT <out-target>
#			CONFIG <in-string>
#			DEPENDS <in-list>)
#
#	Input:
#		CONFIG	: the board to generate the export for
#		DEPENDS	: dependencies
#
#	Output:
#		OUT	: the export target
#
#	Example:
#		px4_nuttx_add_export(OUT nuttx_export CONFIG px4fmu-v2)
#
function(px4_baremetal_add_export)

	px4_parse_function_args(
		NAME px4_baremetal_add_export
		ONE_VALUE OUT CONFIG THREADS
		MULTI_VALUE DEPENDS
		REQUIRED OUT CONFIG THREADS
		ARGN ${ARGN})

	set(baremetal_src ${CMAKE_BINARY_DIR}/baremetal-configs/baremetal-export/build)

	# copy and export
	add_custom_command(OUTPUT ${baremetal_src}
		COMMAND ${MKDIR} -p ${baremetal_src}
		DEPENDS ${DEPENDS}	
			)
	add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/${CONFIG}.export
		#COMMAND ${MKDIR} -p ${baremetal_src}
		COMMAND ${CP} -r ${CMAKE_SOURCE_DIR}/baremetal-configs/${CONFIG}/scripts/*  ${baremetal_src}
		COMMAND cd ${CMAKE_BINARY_DIR}/baremetal-configs && ${ZIP} -q -r ${CMAKE_BINARY_DIR}/baremetal-configs/baremetal_export.zip  baremetal-export 
		COMMAND	${CP} -r ${CMAKE_BINARY_DIR}/baremetal-configs/baremetal_export.zip ${CMAKE_BINARY_DIR}/${CONFIG}.export 	
		DEPENDS ${DEPENDS} ${baremetal_src}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		COMMENT "Building baremetal for ${CONFIG}"
			)
	add_custom_command(OUTPUT baremetal_export_${CONFIG}.stamp
		COMMAND ${RM} -rf ${CMAKE_BINARY_DIR}/baremetal-configs/
		COMMAND ${UNZIP} -q ${CMAKE_BINARY_DIR}/${CONFIG}.export -d ${CMAKE_BINARY_DIR}/baremetal-configs/
		COMMAND ${TOUCH} baremetal_export_${CONFIG}.stamp  
		DEPENDS ${DEPENDS} ${CMAKE_BINARY_DIR}/${CONFIG}.export
			)
	add_custom_target(${OUT}
		DEPENDS baremetal_export_${CONFIG}.stamp
			)

endfunction()

#=============================================================================
#
#	px4_nuttx_create_bin
#
#	The functions generates a bin image for nuttx.
#
#	Usage:
#		px4_nuttx_create_bin(BIN <out-file> EXE <in-file>)
#
#	Input:
#		EXE		: the exe file
#
#	Output:
#		OUT		: the binary output file
#
#	Example:
#		px4_nuttx_create_bin(OUT my_exe.bin EXE my_exe)
#
function(px4_nuttx_create_bin)

	px4_parse_function_args(
		NAME px4_nuttx_create_bin
		ONE_VALUE EXE OUT
		REQUIRED EXE OUT
		ARGN ${ARGN})

	add_custom_command(OUTPUT ${OUT}
		COMMAND ${OBJCOPY} -O binary ${EXE} ${EXE}.bin
		DEPENDS ${EXE})

	set(${OUT} ${${OUT}} PARENT_SCOPE)

endfunction()




#=============================================================================
#
#	px4_os_add_flags
#
#	Set ths nuttx build flags.
#
#	Usage:
#		px4_os_add_flags(
#			C_FLAGS <inout-variable>
#			CXX_FLAGS <inout-variable>
#			EXE_LINKER_FLAGS <inout-variable>
#			INCLUDE_DIRS <inout-variable>
#			LINK_DIRS <inout-variable>
#			DEFINITIONS <inout-variable>)
#
#	Input:
#		BOARD					: flags depend on board/nuttx config
#
#	Input/Output: (appends to existing variable)
#		C_FLAGS					: c compile flags variable
#		CXX_FLAGS				: c++ compile flags variable
#		EXE_LINKER_FLAGS		: executable linker flags variable
#		INCLUDE_DIRS			: include directories
#		LINK_DIRS				: link directories
#		DEFINITIONS				: definitions
#
#	Example:
#		px4_os_add_flags(
#			C_FLAGS CMAKE_C_FLAGS
#			CXX_FLAGS CMAKE_CXX_FLAGS
#			EXE_LINKER_FLAG CMAKE_EXE_LINKER_FLAGS
#			INCLUDES <list>)
#
function(px4_os_add_flags)

	set(inout_vars
		C_FLAGS CXX_FLAGS EXE_LINKER_FLAGS INCLUDE_DIRS LINK_DIRS DEFINITIONS)

	px4_parse_function_args(
		NAME px4_add_flags
		ONE_VALUE ${inout_vars} BOARD
		REQUIRED ${inout_vars} BOARD
		ARGN ${ARGN})

	px4_add_common_flags(
		BOARD ${BOARD}
		C_FLAGS ${C_FLAGS}
		CXX_FLAGS ${CXX_FLAGS}
		EXE_LINKER_FLAGS ${EXE_LINKER_FLAGS}
		INCLUDE_DIRS ${INCLUDE_DIRS}
		LINK_DIRS ${LINK_DIRS}
		DEFINITIONS ${DEFINITIONS})

	set(nuttx_export_dir ${CMAKE_BINARY_DIR}/${BOARD}/NuttX/nuttx-export)
	set(added_include_dirs
		${nuttx_export_dir}/include
		${nuttx_export_dir}/include/cxx
		${nuttx_export_dir}/arch/chip
		${nuttx_export_dir}/arch/common
		)
	set(added_link_dirs
		${nuttx_export_dir}/libs
		)
	set(added_definitions
		-D__PX4_NUTTX
		-D__DF_NUTTX
		)
	set(added_c_flags
		-nodefaultlibs
		-nostdlib
		)
	set(added_cxx_flags
		-nodefaultlibs
		-nostdlib
		)

	set(added_exe_linker_flags) # none currently

	set(instrument_flags)
	if ("${config_nuttx_hw_stack_check_${BOARD}}" STREQUAL "y")
		set(instrument_flags
			-finstrument-functions
			-ffixed-r10
			)
		list(APPEND c_flags ${instrument_flags})
		list(APPEND cxx_flags ${instrument_flags})
	endif()

	set(cpu_flags)
	if (${BOARD} STREQUAL "px4fmu-v1")
		set(cpu_flags
			-mcpu=cortex-m4
			-mthumb
			-march=armv7e-m
			-mfpu=fpv4-sp-d16
			-mfloat-abi=hard
			)
	elseif (${BOARD} STREQUAL "px4fmu-v2")
		set(cpu_flags
			-mcpu=cortex-m4
			-mthumb
			-march=armv7e-m
			-mfpu=fpv4-sp-d16
			-mfloat-abi=hard
			)
	elseif (${BOARD} STREQUAL "px4fmu-v4")
		set(cpu_flags
			-mcpu=cortex-m4
			-mthumb
			-march=armv7e-m
			-mfpu=fpv4-sp-d16
			-mfloat-abi=hard
			)
	elseif (${BOARD} STREQUAL "px4-stm32f4discovery")
		set(cpu_flags
			-mcpu=cortex-m4
			-mthumb
			-march=armv7e-m
			-mfpu=fpv4-sp-d16
			-mfloat-abi=hard
			)
	elseif (${BOARD} STREQUAL "aerocore")
		set(cpu_flags
			-mcpu=cortex-m4
			-mthumb
			-march=armv7e-m
			-mfpu=fpv4-sp-d16
			-mfloat-abi=hard
			)
	elseif (${BOARD} STREQUAL "mindpx-v2")
			set(cpu_flags
			-mcpu=cortex-m4
			-mthumb
			-march=armv7e-m
			-mfpu=fpv4-sp-d16
			-mfloat-abi=hard
			)
	elseif (${BOARD} STREQUAL "px4io-v1")
		set(cpu_flags
			-mcpu=cortex-m3
			-mthumb
			-march=armv7-m
			)
	elseif (${BOARD} STREQUAL "px4io-v2")
		set(cpu_flags
			-mcpu=cortex-m3
			-mthumb
			-march=armv7-m
			)
	endif()
	list(APPEND c_flags ${cpu_flags})
	list(APPEND cxx_flags ${cpu_flags})

	# output
	foreach(var ${inout_vars})
		string(TOLOWER ${var} lower_var)
		set(${${var}} ${${${var}}} ${added_${lower_var}} PARENT_SCOPE)
		#message(STATUS "nuttx: set(${${var}} ${${${var}}} ${added_${lower_var}} PARENT_SCOPE)")
	endforeach()

endfunction()

#=============================================================================
#
#	px4_os_prebuild_targets
#
#	This function generates os dependent targets

#	Usage:
#		px4_os_prebuild_targets(
#			OUT <out-list_of_targets>
#			BOARD <in-string>
#			)
#
#	Input:
#		BOARD 		: board
#		THREADS 	: number of threads for building
#
#	Output:
#		OUT	: the target list
#
#	Example:
#		px4_os_prebuild_targets(OUT target_list BOARD px4fmu-v2)
#
function(px4_os_prebuild_targets)
	px4_parse_function_args(
			NAME px4_os_prebuild_targets
			ONE_VALUE OUT BOARD THREADS
			REQUIRED OUT BOARD
			ARGN ${ARGN})
	px4_baremetal_add_export(OUT baremetal_export_${BOARD}
		CONFIG ${BOARD}
		THREADS ${THREADS})
	add_custom_target(${OUT} DEPENDS baremetal_export_${BOARD})
endfunction()

# vim: set noet fenc=utf-8 ff=unix nowrap:
