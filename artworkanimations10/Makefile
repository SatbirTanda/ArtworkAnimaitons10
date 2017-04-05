include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ArtworkAnimations10
ArtworkAnimations10_FILES = SSTRootListController.m
ArtworkAnimations10_INSTALL_PATH = /Library/PreferenceBundles
ArtworkAnimations10_FRAMEWORKS = UIKit
ArtworkAnimations10_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ArtworkAnimations10.plist$(ECHO_END)
