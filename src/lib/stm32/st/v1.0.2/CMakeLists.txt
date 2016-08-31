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
px4_add_module(
	MODULE lib__stm32__st__v1.0.2
	SRCS
		startup_stm32f4xx.s
		STM32F4xx_StdPeriph_Driver/src/stm32f4xx_rcc.c
		STM32F4xx_StdPeriph_Driver/src/stm32f4xx_dma.c
		STM32F4xx_StdPeriph_Driver/src/stm32f4xx_dcmi.c
		STM32F4xx_StdPeriph_Driver/src/stm32f4xx_i2c.c
		STM32F4xx_StdPeriph_Driver/src/stm32f4xx_tim.c
		STM32F4xx_StdPeriph_Driver/src/stm32f4xx_spi.c
		STM32F4xx_StdPeriph_Driver/src/stm32f4xx_usart.c
		STM32F4xx_StdPeriph_Driver/src/stm32f4xx_adc.c
		STM32F4xx_StdPeriph_Driver/src/stm32f4xx_gpio.c
		STM32F4xx_StdPeriph_Driver/src/misc.c
		STM32_USB_OTG_Driver/src/usb_core.c
		STM32_USB_OTG_Driver/src/usb_dcd_int.c
		STM32_USB_OTG_Driver/src/usb_dcd.c
		STM32_USB_Device_Library/Core/src/usbd_core.c
		STM32_USB_Device_Library/Core/src/usbd_req.c
		STM32_USB_Device_Library/Core/src/usbd_ioreq.c
		STM32_USB_Device_Library/Class/cdc/src/usbd_cdc_core.c
	)
# vim: set noet ft=cmake fenc=utf-8 ff=unix : 
