
#import <QuartzCore/QuartzCore.h>
#import "TiledScrollView.h"
#import "TapDetectingView.h"
#import "ContentButton.h"

#define DEFAULT_TILE_SIZE 100
#define ANNOTATE_TILES YES

@interface TiledScrollView ()
- (void)annotateTile:(UIView *)tile;
- (void)updateResolution;
@end

@implementation TiledScrollView
@synthesize tileSize, imgSize;
@synthesize tileContainerView;
@synthesize dataSource;
@dynamic minimumResolution;
@dynamic maximumResolution;

-(void) setPageId: (int)_pageid{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray* array = (NSMutableArray*)appDelegate.currentIshue.pages;
    NSDictionary* pageinfo = [array objectAtIndex:_pageid-1];
    page_id = [[pageinfo objectForKey:@"id"] integerValue];
    NSLog(@"setPageId: page_id:%d=>%d", _pageid, page_id );
}

- (id)initWithFrame:(CGRect)frame pagenum:(int)pagenum {
    if (self = [super initWithFrame:frame]) {
        // we will recycle tiles by removing them from the view and storing them here
        reusableTiles = [[NSMutableSet alloc] init];
        // we need a tile container view to hold all the tiles. This is the view that is returned
        // in the -viewForZoomingInScrollView: delegate method, and it also detects taps.
        tileContainerView = [[TapDetectingView alloc] initWithFrame:CGRectZero];
        [tileContainerView setBackgroundColor:appDelegate.presetBackgroundColor];
        [self addSubview:tileContainerView];
        [self setTileSize:CGSizeMake(DEFAULT_TILE_SIZE, DEFAULT_TILE_SIZE)];

        // no rows or columns are visible at first; note this by making the firsts very high and the lasts very low
        firstVisibleRow = firstVisibleColumn = NSIntegerMax;
        lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
        
        buttonsForPageUIBUTTONS = [[NSMutableArray alloc] init];
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        page_id = pagenum; //for test to ma byc id z bazy nei numer srtony
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray* array = (NSMutableArray*)appDelegate.currentIshue.pages;
        NSDictionary* pageinfo = [array objectAtIndex:pagenum-1];
        page_id = [[pageinfo objectForKey:@"id"] integerValue];
        NSLog(@"TiledScrollView:initWithFrame: page_id:%d=>%d", pagenum, page_id );
        
//        [NSTimer scheduledTimerWithTimeInterval:.5
//                                         target:self
//                                       selector:@selector(correctButtonsFrames)
//                                       userInfo:nil
//                                        repeats:YES];
        
        
        // the TiledScrollView is its own UIScrollViewDelegate, so we can handle our own zooming.
        // We need to return our tileContainerView as the view for zooming, and we also need to receive
        // the scrollViewDidEndZooming: delegate callback so we can update our resolution.
        [super setDelegate:self];
    }
    return self;
}


-(NSMutableArray*) returnButtonsViewKuwa{
    return buttonsForPageUIBUTTONS;
}
-(NSMutableArray*) returnButtonsForPage{
    return buttonsForPage;
}


+ (UIImage *) imageNamed:(NSString *) name withTintColor: (UIColor *) tintColor {
    
    UIImage *baseImage = [UIImage imageNamed:name];
    
    CGRect drawRect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    UIGraphicsBeginImageContextWithOptions(baseImage.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, baseImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // draw original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, drawRect, baseImage.CGImage);
    
    // draw color atop
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextFillRect(context, drawRect);
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}




-(void)placeXXXButton: (ContentButton*)button frame:(CGRect)frameForView{
    UIView* b = [[UIView alloc] initWithFrame:frameForView ];
    b.layer.borderColor = [UIColor grayColor].CGColor;
    b.tag = button.button_id;
    b.layer.borderWidth = 0.0f;
    b.layer.cornerRadius = 3;
    b.layer.backgroundColor = [UIColor clearColor].CGColor;
    NSLog(@"button.btnico: %@", button.btnico );
    
//    UIImageView* image = [[UIImageView alloc] initWithImage:[TiledScrollView imageNamed:button.btnico withTintColor:[UIColor colorWithRed:6.0f/255.0f green:50.0f/255.0f blue:91.0f/255.0f alpha:1.0]]];
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:button.btnico ]];


    image.frame = CGRectMake(2, 2, 64, 64);
    [b addSubview:image];
    [self addSubview:b];
    [self bringSubviewToFront:b];
    b.backgroundColor = [UIColor clearColor];
//    [UIView animateWithDura48tion:2.5 delay:2.0 options: UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
//        b.backgroundColor = [UIColor colorWithRed:1.0f green:215.0/255.0f blue:0.0f alpha:0.45f];
//        
//    } completion:nil];
    
    
    [buttonsForPageUIBUTTONS addObject:b];
}

-(void)placeButton: (ContentButton*)button leftOrRight:(NSString*)lor {
    float x = (button.position_left/100)*self.frame.size.width;
    float y = (button.position_top/100)*self.frame.size.height;
    float width = (button.position_width/100)*self.frame.size.width;
    float height = (button.position_height/100)*self.frame.size.height;
    CGRect frameForView = CGRectMake( x,y, width, height );
    [self placeXXXButton:button frame:frameForView];
}

-(void)correctButtonsFrames{
    if ( !buttons_corrected ){
//        NSLog(@"correctButtonsFrames NEEDED");
        for (int i=0; i < [buttonsForPageUIBUTTONS count]; i++) {
            UIView* button = [buttonsForPageUIBUTTONS objectAtIndex:i];

            ContentButton* cb = [buttonsForPage objectAtIndex:i];
            float x = (cb.position_left/100)* self.tileContainerView.frame.size.width;
            float y = (cb.position_top/100)* self.tileContainerView.frame.size.height;
            float width = (cb.position_width/100)* self.tileContainerView.frame.size.width;
            float height = (cb.position_height/100)* self.tileContainerView.frame.size.height;

            CGRect frameNew = CGRectMake(x, y, width, height);
            button.frame = frameNew;
        }
//        buttons_corrected = YES;
    }
}


-(void)removeAllButtonsFromView{
    NSLog(@"removeAllButtonsFromView");
    for (int i=0; i < [buttonsForPageUIBUTTONS count]; i++) {
        UIView* button = [buttonsForPageUIBUTTONS objectAtIndex:i];
        [button removeFromSuperview];
    }
    
    [buttonsForPageUIBUTTONS removeAllObjects];
    [buttonsForPage removeAllObjects];
}





-(NSMutableArray*)prepareButtons :(NSString*)lor{
    buttonsForPage = [[NSMutableArray alloc] init];
    
    [self removeAllButtonsFromView];
    Ishue* ishue = appDelegate.currentIshue;
    NSDictionary* buttons = ishue.buttonsForCurrentIshue;
    NSLog( @"prepareButtons => %lu", (unsigned long)[buttons count] );
//    if
    if ( [buttons count] == 0 ){
        return buttonsForPage;
    }
    else{
        NSDictionary* buttonsForThisPage = [buttons objectForKey:[NSString stringWithFormat:@"%d",page_id]];
        NSLog(@"buttons for cur page:%d", page_id );

        for (NSDictionary* buttonData in buttonsForThisPage) {
            NSMutableDictionary* buttonInfo = [[NSMutableDictionary alloc] init];
            [buttonInfo setObject:[buttonData objectForKey:@"ia_id"] forKey:@"button_id"];
            [buttonInfo setObject:[buttonData objectForKey:@"action_type_id"] forKey:@"type_id"];
            [buttonInfo setObject:[buttonData objectForKey:@"full_link"] forKey:@"action"];
            [buttonInfo setObject:[buttonData objectForKey:@"posX"] forKey:@"position_left"];
            [buttonInfo setObject:[buttonData objectForKey:@"posY"] forKey:@"position_top"];
            [buttonInfo setObject:[buttonData objectForKey:@"width"] forKey:@"position_width"];
            [buttonInfo setObject:[buttonData objectForKey:@"height"] forKey:@"position_height"];
            switch ( [[buttonData objectForKey:@"icon_id"] integerValue] ) {
                
                case 1:
                    [buttonInfo setObject:@"ICO_2_A_000000" forKey:@"btnico"];break;
                case 2:
                    [buttonInfo setObject:@"ICO_2_G_000000" forKey:@"btnico"];break;
                case 3:
                    [buttonInfo setObject:@"ICO_2_L_000000" forKey:@"btnico"];break;
                case 4:
                    [buttonInfo setObject:@"ICO_2_V_000000" forKey:@"btnico"];break;
                    
                default:
                    [buttonInfo setObject:@"btn_pdf" forKey:@"btnico"];break;
                    
                    break;
            }
            
            
            [buttonsForPage insertObject:[[ContentButton alloc] initWithDatasId:buttonInfo] atIndex:buttonsForPage.count];

        }


        return buttonsForPage;
    }
}





// we don't synthesize our minimum/maximum resolution accessor methods because we want to police the values of these ivars
- (int)minimumResolution { return minimumResolution; }
- (int)maximumResolution { return maximumResolution; }
- (void)setMinimumResolution:(int)res { minimumResolution = MIN(res, 0); } // you can't have a minimum resolution greater than 0
- (void)setMaximumResolution:(int)res { maximumResolution = MAX(res, 0); } // you can't have a maximum resolution less than 0

- (UIView *)dequeueReusableTile {
    
//    NSLog(@"dequeueReusableTile");
    UIView *tile = [reusableTiles anyObject];
    if (tile) {
        // the only object retaining the tile is our reusableTiles set, so we have to retain/autorelease it
        // before returning it so that it's not immediately deallocated when we remove it from the set
        [reusableTiles removeObject:tile];
    }
    
    return tile;
}


- (void)reloadData {
    // recycle all tiles so that every tile will be replaced in the next layoutSubviews
    for (UIView *view in [tileContainerView subviews]) {
        [reusableTiles addObject:view];
        [view removeFromSuperview];
    }
    
    // no rows or columns are now visible; note this by making the firsts very high and the lasts very low
    firstVisibleRow = firstVisibleColumn = NSIntegerMax;
    lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
    
    [self setNeedsLayout];
}

- (void)reloadDataWithNewContentSize:(CGSize)size {
// NSLog(@"reloadDataWithNewContentSize");
// since we may have changed resolutions, which changes our maximum and minimum zoom scales, we need to
// reset all those values. After calling this method, the caller should change the maximum/minimum zoom scales
// if it wishes to permit zooming.
    
    [self setZoomScale:1.0];
    [self setMinimumZoomScale:1.0];
    [self setMaximumZoomScale:1.0];
    resolution = 0;
    
    // now that we've reset our zoom scale and resolution, we can safely set our contentSize. 
    [self setContentSize:size];
    
    // we also need to change the frame of the tileContainerView so its size matches the contentSize
    [tileContainerView setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    [self reloadData];
    
}

/***********************************************************************************/
/* Most of the work of tiling is done in layoutSubviews, which we override here.   */
/* We recycle the tiles that are no longer in the visible bounds of the scrollView */
/* and we add any tiles that should now be present but are missing.                */
/***********************************************************************************/
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect visibleBounds = [self bounds];

    // first recycle all tiles that are no longer visible
    for (UIView *tile in [tileContainerView subviews]) {
        
        // We want to see if the tiles intersect our (i.e. the scrollView's) bounds, so we need to convert their
        // frames to our own coordinate system
        CGRect scaledTileFrame = [tileContainerView convertRect:[tile frame] toView:self];

        // If the tile doesn't intersect, it's not visible, so we can recycle it
        if (! CGRectIntersectsRect(scaledTileFrame, visibleBounds)) {
            [reusableTiles addObject:tile];
            [tile removeFromSuperview];
        }
    }
    
    // calculate which rows and columns are visible by doing a bunch of math.
    float scaledTileWidth  = [self tileSize].width  * [self zoomScale];
    float scaledTileHeight = [self tileSize].height * [self zoomScale];
    int maxRow = floorf([tileContainerView frame].size.height / scaledTileHeight); // this is the maximum possible row
    int maxCol = floorf([tileContainerView frame].size.width  / scaledTileWidth);  // and the maximum possible column
    int firstNeededRow = MAX(0, floorf(visibleBounds.origin.y / scaledTileHeight));
    int firstNeededCol = MAX(0, floorf(visibleBounds.origin.x / scaledTileWidth));
    int lastNeededRow  = MIN(maxRow, floorf(CGRectGetMaxY(visibleBounds) / scaledTileHeight));
    int lastNeededCol  = MIN(maxCol, floorf(CGRectGetMaxX(visibleBounds) / scaledTileWidth));
    
//    NSLog(@"firstNeeded Row: %d Col:%d" , firstNeededRow, firstNeededCol );
    // iterate through needed rows and columns, adding any tiles that are missing
    for (int row = firstNeededRow; row <= lastNeededRow; row++) {
        for (int col = firstNeededCol; col <= lastNeededCol; col++) {

            BOOL tileIsMissing = (firstVisibleRow > row || firstVisibleColumn > col || 
                                  lastVisibleRow  < row || lastVisibleColumn  < col);
            
            tileIsMissing = true;
            if (tileIsMissing) {
                UIView *tile = [dataSource tiledScrollView:self tileForRow:row column:col resolution:resolution];
                                
                // set the tile's frame so we insert it at the correct position
                CGRect frame = CGRectMake([self tileSize].width * col, [self tileSize].height * row, [self tileSize].width, [self tileSize].height);
                [tile setFrame:frame];
                [tileContainerView addSubview:tile];
                
                // annotateTile draws green lines and tile numbers on the tiles for illustration purposes. 
                [self annotateTile:tile];
                
            }
        }
    }
    
    // update our record of which rows/cols are visible
    firstVisibleRow = firstNeededRow; firstVisibleColumn = firstNeededCol;
    lastVisibleRow  = lastNeededRow;  lastVisibleColumn  = lastNeededCol;            
}


/*****************************************************************************************/
/* The following method handles changing the resolution of our tiles when our zoomScale  */
/* gets below 50% or above 100%. When we fall below 50%, we lower the resolution 1 step, */
/* and when we get above 100% we raise it 1 step. The resolution is stored as a power of */
/* 2, so -1 represents 50%, and 0 represents 100%, and so on.                            */
/*****************************************************************************************/
- (void)updateResolution {
    
    // delta will store the number of steps we should change our resolution by. If we've fallen below
    // a 25% zoom scale, for example, we should lower our resolution by 2 steps so delta will equal -2.
    // (Provided that lowering our resolution 2 steps stays within the limit imposed by minimumResolution.)
    int delta = 0;
//    tileContainerView.center = [self convertPoint:self.center fromView:self.superview];
    // check if we should decrease our resolution
    for (int thisResolution = minimumResolution; thisResolution < resolution; thisResolution++) {
        int thisDelta = thisResolution - resolution;
        // we decrease resolution by 1 step if the zoom scale is <= 0.5 (= 2^-1); by 2 steps if <= 0.25 (= 2^-2), and so on
        float scaleCutoff = pow(2, thisDelta); 
        if ([self zoomScale] <= scaleCutoff) {
            delta = thisDelta;
            break;
        } 
    }
    
    // if we didn't decide to decrease the resolution, see if we should increase it
    if (delta == 0) {
        for (int thisResolution = maximumResolution; thisResolution > resolution; thisResolution--) {
            int thisDelta = thisResolution - resolution;
            // we increase by 1 step if the zoom scale is > 1 (= 2^0); by 2 steps if > 2 (= 2^1), and so on
            float scaleCutoff = pow(2, thisDelta - 1); 
            if ([self zoomScale] > scaleCutoff) {
                delta = thisDelta;
                break;
            } 
        }
    }
    
    if (delta != 0) {
        resolution += delta;
        
        // if we're increasing resolution by 1 step we'll multiply our zoomScale by 0.5; up 2 steps multiply by 0.25, etc
        // if we're decreasing resolution by 1 step we'll multiply our zoomScale by 2.0; down 2 steps by 4.0, etc
        float zoomFactor = pow(2, delta * -1); 
        
        // save content offset, content size, and tileContainer size so we can restore them when we're done
        // (contentSize is not equal to containerSize when the container is smaller than the frame of the scrollView.)
        CGPoint contentOffset = [self contentOffset];   
        CGSize  contentSize   = [self contentSize];
        CGSize  containerSize = [tileContainerView frame].size;
        
        // adjust all zoom values (they double as we cut resolution in half)
        [self setMaximumZoomScale:[self maximumZoomScale] * zoomFactor];
        [self setMinimumZoomScale:[self minimumZoomScale] * zoomFactor];
        [super setZoomScale:[self zoomScale] * zoomFactor];
        
        // restore content offset, content size, and container size
        [self setContentOffset:contentOffset];
        [self setContentSize:contentSize];
        [tileContainerView setFrame:CGRectMake(0, 0, containerSize.width, containerSize.height)];    
        
        // throw out all tiles so they'll reload at the new resolution
        [self reloadData];        
    }
    
//    NSLog(@"updateResolution");
}
        
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    NSLog(@"scrollViewWillEndDragging");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"scrollViewDidEndDragging");
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
//    NSLog(@"scrollViewWillBeginZooming");
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return tileContainerView;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
//    NSLog(@"scrollViewDidEndDecelerating");
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(double)scale {
//    NSLog(@"scrollViewDidEndZooming: %f", scale);
    if (scrollView == self) {
        
        // the following two lines are a bug workaround that will no longer be needed after OS 3.0.
        [super setZoomScale:scale+0.01 animated:NO];
        [super setZoomScale:scale animated:NO];
        
        
        // after a zoom, check to see if we should change the resolution of our tiles
        [self updateResolution];
        
    }
}

#pragma mark UIScrollView overrides

// the scrollViewDidEndZooming: delegate method is only called after an *animated* zoom. We also need to update our 
// resolution for non-animated zooms. So we also override the new setZoomScale:animated: method on UIScrollView
- (void)setZoomScale:(double)scale animated:(BOOL)animated {
    [super setZoomScale:scale animated:animated];
    
    // the delegate callback will catch the animated case, so just cover the non-animated case
    if (!animated) {
        [self updateResolution];
    }
}

// We override the setDelegate: method because we can't manage resolution changes unless we are our own delegate.
- (void)setDelegate:(id)delegate {
    NSLog(@"You can't set the delegate of a TiledZoomableScrollView. It is its own delegate.");
}


#pragma mark
#define LABEL_TAG 3

- (void)annotateTile:(UIView *)tile {
    static int totalTiles = 0;
    
    UILabel *label = (UILabel *)[tile viewWithTag:LABEL_TAG];
    if (!label) {  
        totalTiles++;
        
        [[tile layer] setBorderWidth:0];
        [[tile layer] setBorderColor:[[UIColor greenColor] CGColor]];
    }
    
    [tile bringSubviewToFront:label];
}


@end
