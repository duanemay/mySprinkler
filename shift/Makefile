VERSION=1.0.0

BUILD_DIR=build
CC=gcc
CCFLAGS=-O3 -Wall -fmessage-length=0 -MMD -MP -DLOGGING

CPP_SRCS += \
data.cpp 

LIBS := -lwiringPi
LIBNAME=data

OBJS=$(CPP_SRCS:%.cpp=$(BUILD_DIR)/%.o)

all: build_dir $(LIBNAME)

$(LIBNAME): $(OBJS)
	@echo 'Building target: $@'
	g++  -o "$@" $(OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

build_dir: ${BUILD_DIR}

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}

$(BUILD_DIR)/%.o: %.cpp
	$(CC) $(CCFLAGS) -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -c -o "$@" "$<"

.PHONY: build_dir

#Misc stuff below here..

