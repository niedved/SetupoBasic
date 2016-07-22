

/************************************** NOTE **************************************/
/* For detailed comments on the ThumbImageView class, please see the Autoscroll   */
/* project in this sample code suite.                                             */
/**********************************************************************************/

#import "ThumbImageView.h"
#import "AppDelegate.h"
#import "NHelper.h"

#define DRAG_THRESHOLD 10

float distanceBetweenPoints(CGPoint a, CGPoint b);

@implementation ThumbImageView
@synthesize delegate;
@synthesize imageName;
@synthesize imageSize;
@synthesize home;
@synthesize touchLocation;

- (id)initWithImage:(UIImage *)image {
    
    self = [super initWithImage:image];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self->imaged = NO;
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];
        [self prepareTap];
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [NHelper colorFromHexString:@"#dfdfdf"].CGColor;
        
    }
    return self;
}


-(void) setThumbWithImage: (int)currentPage ishue_id:(int)ishue_id{
    imaged = YES;
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"thumb_%d_%d.jpg", ishue_id, currentPage]];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]) {
        NSData *imageData = [NSData dataWithContentsOfFile:fullFilePath];
        UIImage *thumbImage = [UIImage imageWithData:imageData];
        [self setImage:thumbImage];
    }
}





-(void) prepareTap{
//    [AppDelegate LogIt:(@"prepareTapForThumb")];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    tap.delegate = self;
    [self addGestureRecognizer:tap];
}


-(void) handleTap:(UITapGestureRecognizer *)gestureRecognizer {
//    CGPoint location = [gestureRecognizer locationInView:self];
    NSLog(@"TAPED THUMB!!!!: %d", imageId );
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.rootViewController setPageLeftPageNumSpec:imageId];
//    if ([delegate respondsToSelector:@selector(setPageLeftPageNumSpec:)]){
//        [delegate setPageLeftPageNumSpec:imageId];
//    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
    // store the location of the starting touch so we can decide when we've moved far enough to drag
    touchLocation = [[touches anyObject] locationInView:self];
    if ([delegate respondsToSelector:@selector(thumbImageViewStartedTracking:)])
        [delegate thumbImageViewStartedTracking:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (dragging) {
        [self goHome];
        dragging = NO;
    } else if ([[touches anyObject] tapCount] == 1) {
        if ([delegate respondsToSelector:@selector(thumbImageViewWasTapped:)])
            [delegate thumbImageViewWasTapped:self];
    }
    
    if ([delegate respondsToSelector:@selector(thumbImageViewStoppedTracking:)]) 
        [delegate thumbImageViewStoppedTracking:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self goHome];
    dragging = NO;
    if ([delegate respondsToSelector:@selector(thumbImageViewStoppedTracking:)]) 
        [delegate thumbImageViewStoppedTracking:self];
}

- (void)goHome {
    float distanceFromHome = distanceBetweenPoints([self frame].origin, [self home].origin); // distance is in pixels
    float animationDuration = 0.1 + distanceFromHome * 0.001;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self setFrame:[self home]];
    [UIView commitAnimations];
}
    
- (void)moveByOffset:(CGPoint)offset {
    CGRect frame = [self frame];
    frame.origin.x += offset.x;
    frame.origin.y += offset.y;
    [self setFrame:frame];
    if ([delegate respondsToSelector:@selector(thumbImageViewMoved:)])
        [delegate thumbImageViewMoved:self];
}    

@end

float distanceBetweenPoints(CGPoint a, CGPoint b) {
    float deltaX = a.x - b.x;
    float deltaY = a.y - b.y;
    return sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
}
            
