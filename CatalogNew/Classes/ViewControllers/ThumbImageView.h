

@protocol ThumbImageViewDelegate;


@interface ThumbImageView : UIImageView {
  __unsafe_unretained  id <ThumbImageViewDelegate> delegate;
    NSString *imageName;
    
    CGSize imageSize;
    CGRect home;
    BOOL dragging;
    CGPoint touchLocation; // Location of touch in own coordinates (stays constant during dragging).
    
    
    @public
    int imageId;
    BOOL imaged;
    
}

@property (nonatomic, assign) id <ThumbImageViewDelegate> delegate;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGRect home;
@property (nonatomic, assign) CGPoint touchLocation;

-(void) setThumbWithImage: (int)currentPage ishue_id:(int)ishue_id;
- (void)goHome;
- (void)moveByOffset:(CGPoint)offset;

@end



@protocol ThumbImageViewDelegate <NSObject>

@optional
- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv;
- (void)thumbImageViewStartedTracking:(ThumbImageView *)tiv;
- (void)thumbImageViewMoved:(ThumbImageView *)tiv;
- (void)thumbImageViewStoppedTracking:(ThumbImageView *)tiv;
-(void) setPageLeftPageNumSpec: (int)left;

@end

