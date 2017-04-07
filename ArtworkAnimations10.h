#import <MediaPlayer/MPMusicPlayerController.h>

@interface SBDashBoardMediaArtworkViewController : UIViewController
- (void)getTrackDescription:(id)notification;
- (BOOL)isTweakEnabled;
- (BOOL)isBackgroundAnimationEnabled;
- (NSString *)getAnimationKey;
- (int)currentAnimation;
@end

@interface MPUNowPlayingArtworkView : UIView
@end

@interface SBFStaticWallpaperImageView : UIImageView
@end

static NSDictionary *preferences = nil;

static MPMusicPlayerController *myPlayer = nil;
static NSNotificationCenter *notificationCenter = nil;
static MPUNowPlayingArtworkView *artworkView = nil;
static SBFStaticWallpaperImageView *wallpaper = nil;
static UIImage *originalImage = nil;
static bool artworkIsAnimating = NO;
static bool wallPaperIsAnimating = NO;
typedef void(^ViewBlock)(UIView *view, BOOL *stop);

@interface UIView (ViewExtensions)
- (void) loopViewHierarchy:(ViewBlock) block;
@end

@implementation UIView (ViewExtensions)
- (void) loopViewHierarchy:(ViewBlock) block 
{
    BOOL stop = NO;
    if (block) 
    {
        block(self, &stop);
    }
    if (!stop) 
    {
        for (UIView* subview in self.subviews) 
        {
            [subview loopViewHierarchy:block];
        }
    }
}
@end