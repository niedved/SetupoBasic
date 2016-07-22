
#import <UIKit/UIKit.h>
#import "DBController.h"

@interface BookMarksVC : UIViewController<UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
UICollectionViewDelegate, UIGestureRecognizerDelegate>{
    DBController* DBC;
    NSDictionary* ishues;
    
    
}

@property(nonatomic, strong) NSMutableDictionary *searchResults;
@property(nonatomic, strong) NSMutableArray *searches;
@property(nonatomic, strong) IBOutlet UIView *topBarView, *topbarPoziomaLinia;
@property(nonatomic, strong) IBOutlet UIView *loadViewController;

@property (nonatomic, strong) UIView* modalView;
@property (nonatomic, strong) IBOutlet UILabel* labelTop;
@property (nonatomic, strong) IBOutlet UIButton* backButton;


-(IBAction)hide:(id)sender;

-(void)correct;

@end