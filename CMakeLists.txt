cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

#=============================================================================
# parameters
#

set(CMAKE_BUILD_TYPE "" CACHE STRING "build type")
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY
	STRINGS ";Debug;Release;RelWithDebInfo;MinSizeRel")
set(CONFIG "px4flow-v1_default" CACHE STRING "desired configuration")
file(GLOB_RECURSE configs RELATIVE cmake/configs "cmake/configs/*.cmake")
set_property(CACHE CONFIG PROPERTY STRINGS ${configs})
set(THREADS "4" CACHE STRING
	"number of threads to use for external build processes")
set(DEBUG_PORT "/dev/ttyACM0" CACHE STRING "debugging port")

#=============================================================================
# configuration
#
# must come before project to set toolchain

string(REPLACE "_" ";" config_args ${CONFIG})
list(GET config_args 0 BOARD)
list(GET config_args 1 LABEL)
set(target_name "${BOARD}-${LABEL}")

message(STATUS "${target_name}")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
set(config_module "configs/${CONFIG}")
include(${config_module})

set(px4_required_config
	    config_module_list
	    )
foreach(conf ${px4_required_config})
	if(NOT DEFINED ${conf})
		message(FATAL_ERROR "cmake/${config_module} must define ${conf}")
	endif()
endforeach()



#=============================================================================
# project definition
#
project(px4 CXX C ASM)
if (NOT ${CMAKE_VERSION} VERSION_LESS 3.0.0)
	cmake_policy(SET CMP0045 NEW) # error on non-existent target in get prop
	cmake_policy(SET CMP0046 NEW) # no non-existent targets as dependencies
	cmake_policy(SET CMP0025 OLD) # still report AppleClang as Clang
endif()
if (NOT ${CMAKE_VERSION} VERSION_LESS 3.1.0)
	cmake_policy(SET CMP0054 NEW) 
	cmake_policy(SET CMP0015 NEW)# don't dereference quoted variables
endif()

#=============================================================================
# programs
#
find_package(PythonInterp REQUIRED)

#=============================================================================
# cmake modules
#
enable_testing()

#=============================================================================
# check required toolchain variables
#
set(required_variables
	CMAKE_C_COMPILER_ID
	)
foreach(var ${required_variables})
	if (NOT ${var})
		message(FATAL_ERROR "Toolchain/config must define ${var}")
	endif()
endforeach()

#=============================================================================
# build flags
#
px4_add_common_flags(
	BOARD ${BOARD}
	C_FLAGS c_flags
	CXX_FLAGS cxx_flags
	EXE_LINKER_FLAGS exe_linker_flags
	INCLUDE_DIRS include_dirs
	LINK_DIRS link_dirs
	DEFINITIONS definitions)

px4_join(OUT CMAKE_EXE_LINKER_FLAGS LIST "${exe_linker_flags}" GLUE " ")
px4_join(OUT CMAKE_C_FLAGS LIST "${c_flags}" GLUE " ")
px4_join(OUT CMAKE_CXX_FLAGS LIST "${cxx_flags}" GLUE " ")

include_directories(${include_dirs})
#message("INCLUDE_DIRS=${include_dirs}")
link_directories(${link_dirs})
add_definitions(-D__PX4_BAREMETAL ${definitions})

px4_os_prebuild_targets(OUT prebuild_targets
	BOARD ${BOARD}
	THREADS ${1}
	)

#=============================================================================
# subdirectories
#
set(module_libraries)
foreach(module ${config_module_list})	
		add_subdirectory(src/${module})
	px4_mangle_name(${module} mangled_name)
	list(APPEND module_libraries ${mangled_name})
	#message(STATUS "adding module: ${module}")
endforeach()
add_subdirectory(src/modules/flow)



