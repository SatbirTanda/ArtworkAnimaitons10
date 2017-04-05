export ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ArtworkAnimations10
ArtworkAnimations10_FILES = Tweak.xm
ArtworkAnimations10_FRAMEWORKS = UIKit MediaPlayer QuartzCore
ArtworkAnimations10_CFLAGS = "-Wno-error"

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += artworkanimations10
include $(THEOS_MAKE_PATH)/aggregate.mk
