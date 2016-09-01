include(nuttx/px4_impl_nuttx)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/toolchains/Toolchain-arm-none-eabi.cmake)


set(config_module_list
	#
	# Board support modules
	#
	drivers/boards/px4flow-v1
#	drivers/bootloaders/src/common
#	drivers/bootloaders/src/util
	
	lib/stm32/st/v1.0.2
	#modules/flow
	modules/libc
	platforms/common
	
)




