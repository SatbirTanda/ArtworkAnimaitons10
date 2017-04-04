#import "ArtworkAnimations10.h"

%hook SBDashBoardMediaArtworkViewController

%new
- (void)getTrackDescription:(id)notification
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
		if(!artworkIsAnimating)
		{
			artworkIsAnimating = YES;
			[UIView transitionWithView:artworkImageView 
										duration:0.75 
										options:4 << 20 
										animations:^{ artworkImageView.image = currentImage; } 
										completion:^(BOOL finished) { if (finished) artworkIsAnimating = NO; }];
		}
	}
}

- (void)viewDidAppear:(id)arg1
{
	%orig;

    // creating simple audio player
    myPlayer = [MPMusicPlayerController systemMusicPlayer];

    notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter addObserver:self
	                    selector:@selector(getTrackDescription:)
	                        name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
	                        object:myPlayer];

    [myPlayer beginGeneratingPlaybackNotifications];
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
}

%end