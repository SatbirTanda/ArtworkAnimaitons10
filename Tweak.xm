#import "ArtworkAnimations10.h"
#define PLIST_FILENAME @"/var/mobile/Library/Preferences/com.sst1337.ArtworkAnimations10.plist"
#define TWEAK "com.sst1337.ArtworkAnimations10"
//PLIST KEYS
#define ONOFF "OnOff"
#define ANIMATION "Animation"
#define BACKGROUND "Background"

/*ANIMATIONS:*/
#define FLIP_RIGHT @"Flip Right"
#define FLIP_LEFT @"Flip Left"
#define FLIP_TOP @"Flip Top"
#define FLIP_BOTTOM @"Flip Bottom"
#define CURL_UP @"Curl Up"
#define CURL_DOWN @"Curl Down"
#define DISSOVLE @"Dissolve"
#define RANDOM @"Random"

%hook SBDashBoardMediaArtworkViewController

%new
- (BOOL)isTweakEnabled
{
	CFPreferencesAppSynchronize(CFSTR(TWEAK));
	CFPropertyListRef value = CFPreferencesCopyAppValue(CFSTR(ONOFF), CFSTR(TWEAK));
	if(value == nil) return YES;  
	return [CFBridgingRelease(value) boolValue];
}

%new
- (BOOL)isBackgroundAnimationEnabled
{
	CFPreferencesAppSynchronize(CFSTR(TWEAK));
	CFPropertyListRef value = CFPreferencesCopyAppValue(CFSTR(BACKGROUND), CFSTR(TWEAK));
	if(value == nil) return YES;  
	return [CFBridgingRelease(value) boolValue];
}

%new
- (NSString *)getAnimationKey
{
	CFPreferencesAppSynchronize(CFSTR(TWEAK));
	CFPropertyListRef value = CFPreferencesCopyAppValue(CFSTR(ANIMATION), CFSTR(TWEAK));
	NSString *animation = (NSString *)CFBridgingRelease(value);
	if(animation != nil) return animation;
	return RANDOM;
}

%new
- (int)currentAnimation
{
	NSString *key = [self getAnimationKey];
	if([key isEqualToString: FLIP_RIGHT]) return 2 << 20;
	else if([key isEqualToString: FLIP_LEFT]) return 1 << 20;
	else if([key isEqualToString: FLIP_TOP]) return 6 << 20;
	else if([key isEqualToString: FLIP_BOTTOM]) return 7 << 20;
	else if([key isEqualToString: CURL_UP]) return 3 << 20;
	else if([key isEqualToString: CURL_DOWN]) return 4 << 20;
	else if([key isEqualToString: DISSOVLE]) return 5 << 20;
	else
	{
		int animationValues[7] = {2 << 20, 1 << 20, 6 << 20, 7 << 20, 5 << 20, 3 << 20, 4 << 20};
		int randomIndex = arc4random() % 7;
		return animationValues[randomIndex];
	}
}

%new
- (void)getTrackDescription:(id)notification
{
	if([self isTweakEnabled])
	{
		if(artworkView == nil)
		{
			[self.view loopViewHierarchy:^(UIView* view, BOOL* stop) 
			{
			    if ([view isKindOfClass:[%c(MPUNowPlayingArtworkView) class]]) 
			    {
			        /// use the view
			        artworkView = (MPUNowPlayingArtworkView *)view;
			        *stop = YES;
			    }
			}];
		}
		if(artworkView)
		{
			UIImageView *artworkImageView = MSHookIvar<UIImageView *>(artworkView, "_artworkImageView");
			MPMediaItem *nowPlayingItem = myPlayer.nowPlayingItem;
	    	MPMediaItemArtwork *artwork = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
			UIImage *currentImage = [artwork imageWithSize:artworkView.frame.size];	
			if(wallpaper && !wallPaperIsAnimating && [self isBackgroundAnimationEnabled])
			{
				wallPaperIsAnimating = YES;
				[UIView transitionWithView:wallpaper 
											duration:0.75 
											options: UIViewAnimationOptionTransitionCrossDissolve 
											animations:^{ wallpaper.image = currentImage; } 
											completion:^(BOOL finished) { if (finished) wallPaperIsAnimating = NO; }];
			}			
			if(!artworkIsAnimating)
			{
				artworkIsAnimating = YES;
				[UIView transitionWithView:artworkImageView 
											duration:0.75 
											options:[self currentAnimation] 
											animations:^{ artworkImageView.image = currentImage; } 
											completion:^(BOOL finished) { if (finished) artworkIsAnimating = NO; }];
			}
		}
	}
}

- (void)viewDidAppear:(id)arg1
{
	%orig;

	if([self isTweakEnabled])
	{
	    // creating simple audio player
	    myPlayer = [MPMusicPlayerController systemMusicPlayer];

	    notificationCenter = [NSNotificationCenter defaultCenter];

		[notificationCenter addObserver:self
		                    selector:@selector(getTrackDescription:)
		                        name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
		                        object:myPlayer];

	    [myPlayer beginGeneratingPlaybackNotifications];

		if([self isBackgroundAnimationEnabled])
		{
		    NSArray *windows = [UIApplication sharedApplication].windows;
		    for (UIWindow *window in windows) 
		    {
		        if ([NSStringFromClass([window class]) isEqualToString:@"_SBWallpaperWindow"]) 
		        {
					[window loopViewHierarchy:^(UIView* view, BOOL* stop) 
					{
					    if ([view isKindOfClass:[%c(SBFStaticWallpaperImageView) class]]) 
					    {
					        /// use the view
					        wallpaper = (SBFStaticWallpaperImageView *)view;
					        *stop = YES;
					    }
					}];
					break;
		        }
		    }

		    if(wallpaper) originalImage = wallpaper.image;
		}
	}
}

- (void)viewWillDisappear:(id)arg1
{
	%orig;
	if(wallpaper && originalImage) wallpaper.image = originalImage;
}

- (void)viewDidDisappear:(id)arg1
{
	%orig;
	
	[notificationCenter removeObserver:self
	                        	name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
	                        	object:myPlayer];

    [myPlayer endGeneratingPlaybackNotifications];

    myPlayer = nil;

    notificationCenter = nil;

    artworkView = nil;

    wallpaper = nil;

    originalImage = nil;
}

%end