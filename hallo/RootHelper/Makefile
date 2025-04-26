TARGET := iphone:clang:latest:11.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = RootHelper

RootHelper_FILES = $(wildcard *.m)
RootHelper_CFLAGS = -fobjc-arc
RootHelper_CODESIGN_FLAGS = -Sentitlements.plist
RootHelper_INSTALL_PATH = /usr/local/bin
RootHelper_PRIVATE_FRAMEWORKS = MobileCoreServices
include $(THEOS_MAKE_PATH)/tool.mk
