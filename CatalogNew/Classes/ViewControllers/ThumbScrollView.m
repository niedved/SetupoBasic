

/************************************** NOTE **************************************/
/* For detailed comments on the ThumbImageView class, please see the Autoscroll   */
/* project in this sample code suite.                                             */
/**********************************************************************************/

#import "ThumbScrollView.h"
#import "RootViewControllerL1a.h"
#import "AppDelegate.h"
#import "NHelper.h"

#define THUMB_HEIGHT 105
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 10
#define AUTOSCROLL_THRESHOLD 30


@implementation ThumbScrollView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:nil];
        [self setCanCancelContentTouches:NO];
        [self setClipsToBounds:NO];
        self.tag = 666;
        
        self.layer.borderWidth = 1.5f;
        self.layer.borderColor = [NHelper colorFromHexString:@"#333333"].CGColor;
        

    }
    return self;
}


-(ThumbImageView*) prepareThumbImageViewEmpty: (int)num page_id:(int)page_id xPosition:(float)xPosition page:(Page*)page{
    //    thumbImage
    ThumbImageView *thumbView = [[ThumbImageView alloc] initWithImage:nil];
    thumbView.tag = num;
    thumbView->imageId = page_id;
//    [thumbView setDelegate:appDelegate.rootViewController];
    
    float propx = page.page_prop;
    [thumbView setFrame:CGRectMake(0, 0, (THUMB_HEIGHT - THUMB_V_PADDING) / propx, (THUMB_HEIGHT - THUMB_V_PADDING) )];
    [thumbView setImageSize:CGSizeMake(150*propx, 150)];
    
    
    return thumbView;
}


-(void)preapreColectionOfEmptyThumbViews{
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // now place all the thumb views as subviews of the scroll view
    // and in the course of doing so calculate the content width
    float xPosition = THUMB_H_PADDING;
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDictionary* array = (NSDictionary*)appDelegate.currentIshue.pages;
    int num = 1;
    NSLog(@"createThumbScrollViewIfNecessary C");
    
    for (NSDictionary* page in array) {
        
        int page_id = [[page objectForKey:@"id"] intValue];
        
        NSString *fullFilePath = [documentsDirectory stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"thumb_%d_%d.jpg", appDelegate.currentIshue->ishue_id, num]];
        
        
        Page* opage = [[Page alloc] initWithPageId:page_id issue:appDelegate.currentIshue];
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]) {
            ThumbImageView* thumbView = [self prepareThumbImageViewEmpty:num page_id:page_id xPosition:xPosition page:opage];
            CGRect frame = [thumbView frame];
            frame.origin.y = THUMB_V_PADDING-7;
            frame.origin.x = xPosition;
            [thumbView setFrame:frame];
            [thumbView setHome:frame];
            [self addSubview:thumbView];
            
            
            UILabel* topic = [[UILabel alloc] init];
            CGRect frame2 = [thumbView frame];
            frame2.origin.y = 93;
            frame2.origin.x = xPosition;
            frame2.size.height = 20;
            [topic setFrame:frame2];
            [topic setText:[NSString stringWithFormat:@"%d", num]];
            
            [NHelper setColorLabelFromPlistForView:topic key:@"thumbtext"];
            [topic setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.0f]];
            [topic setTextAlignment:NSTextAlignmentCenter];
            topic.layer.borderWidth = 0.0f;
            [self addSubview:topic];
            num++;
            //                [thumbView release];
            xPosition += (frame.size.width + THUMB_H_PADDING);
        }
        else{
            NSLog(@"no file");
        }
    }
    
    
    NSLog(@"createThumbScrollViewIfNecessary D");
    
    [self setContentSize:CGSizeMake(xPosition, THUMB_HEIGHT + THUMB_V_PADDING)];
    
    
}

@end