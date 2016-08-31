############################################################################
#
# Copyright (c) 2015 - 2016 PX4 Development Team. All rights reserved.
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

# Enforce the presence of the GIT repository
#
# We depend on our submodules, so we have to prevent attempts to
# compile without it being present.
ifeq ($(wildcard .git),)
    $(error YOU HAVE TO USE GIT TO DOWNLOAD THIS REPOSITORY. ABORTING.)
endif

CMAKE_VER := $(shell Tools/check_cmake.sh; echo $$?)
ifneq ($(CMAKE_VER),0)
    $(warning Not a valid CMake version or CMake not installed.)
    $(warning On Ubuntu, install or upgrade via:)
    $(warning )
    $(warning 3rd party PPA:)
    $(warning sudo add-apt-repository ppa:george-edison55/cmake-3.x -y)
    $(warning sudo apt-get update)
    $(warning sudo apt-get install cmake)
    $(warning )
    $(warning Official website:)
    $(warning wget https://cmake.org/files/v3.3/cmake-3.3.2-Linux-x86_64.sh)
    $(warning chmod +x cmake-3.3.2-Linux-x86_64.sh)
    $(warning sudo mkdir /opt/cmake-3.3.2)
    $(warning sudo ./cmake-3.3.2-Linux-x86_64.sh --prefix=/opt/cmake-3.3.2 --exclude-subdir)
    $(warning export PATH=/opt/cmake-3.3.2/bin:$$PATH)
    $(warning )
    $(error Fatal)
endif

# Help
# --------------------------------------------------------------------
# Don't be afraid of this makefile, it is just passing
# arguments to cmake to allow us to keep the wiki pages etc.
# that describe how to build the px4 firmware
# the same even when using cmake instead of make.
#
# Example usage:
#
# make px4fmu-v2_default 			(builds)
# make px4fmu-v2_default upload 	(builds and uploads)
# make px4fmu-v2_default test 		(builds and tests)
#
# This tells cmake to build the nuttx px4fmu-v2 default config in the
# directory build_nuttx_px4fmu-v2_default and then call make
# in that directory with the target upload.

#  explicity set default build target
all: px4flow-v1_default

# Parsing
# --------------------------------------------------------------------
# assume 1st argument passed is the main target, the
# rest are arguments to pass to the makefile generated
# by cmake in the subdirectory
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
j ?= 1
PX4_CMAKE_GENERATOR ?= "Unix Makefiles"
PX4_MAKE = make
PX4_MAKE_ARGS = -j$(j) --no-print-directory


# Functions
# --------------------------------------------------------------------
# describe how to build a cmake config
define cmake-build
+@if [ ! -e $(PWD)/build_$@/CMakeCache.txt ]; then Tools/check_submodules.sh && mkdir -p $(PWD)/build_$@ && cd $(PWD)/build_$@ && cmake .. -G$(PX4_CMAKE_GENERATOR) -DCONFIG=$(1) || (cd .. && rm -rf $(PWD)/build_$@); fi
+@Tools/check_submodules.sh
+@(echo "PX4 CONFIG: $@" && cd $(PWD)/build_$@ && $(PX4_MAKE) $(PX4_MAKE_ARGS) $(ARGS))
endef


# create empty targets to avoid msgs for targets passed to cmake
define cmake-targ
$(1):
	@#
.PHONY: $(1)
endef

# ADD CONFIGS HERE
# --------------------------------------------------------------------
#  Do not put any spaces between function arguments.

px4flow-v1_default:
	$(call cmake-build,px4flow-v1_default)


# Other targets
# --------------------------------------------------------------------

.PHONY:  clean 
.NOTPARALLEL: clean

clean:
	@rm -rf build_*/

# targets handled by cmake
cmake_targets =  upload-usb 
$(foreach targ,$(cmake_targets),$(eval $(call cmake-targ,$(targ))))

.PHONY: clean

CONFIGS:=$(shell ls cmake/configs | sed -e "s~.*/~~" | sed -e "s~\..*~~")

#help:
#	@echo
#	@echo "Type 'make ' and hit the tab key twice to see a list of the available"
#	@echo "build configurations."
#	@echo
