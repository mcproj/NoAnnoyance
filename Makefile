THEOS_DEVICE_IP = 192.168.11.10

ARCHS = armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

THEOS_INCLUDE_PATH = include -I . -I $(THEOS)/include

TWEAK_NAME = NoAnnoyance
NoAnnoyance_FILES = Tweak.xm SpringBoard.xm NoAnnoyance.xm
NoAnnoyance_FRAMEWORKS = CoreFoundation UIKit
NoAnnoyance_LDFLAGS = -lMobileGestalt
NoAnnoyance_CFLAGS = -fobjc-arc -O3

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += noannoyanceprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
