ARCHS = armv7 armv7s arm64 arm64e

include $(THEOS)/makefiles/common.mk

# this is baaad
THEOS_INCLUDE_PATH = include -I . -I /opt/theos/include

export ARCHS = armv7 arm64

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
