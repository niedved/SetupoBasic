#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>


@interface VideoViewController : UIViewController<AVAudioPlayerDelegate>{
    AppDelegate *appDelegate;

}


@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) NSString *movieUrl;

- (void)canRotate;

-(void)playMovie: (NSString*)url_string;
@end
