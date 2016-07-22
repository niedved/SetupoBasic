#import <Foundation/Foundation.h>
#import "DBController.h"
#import "Ishue.h"
@interface Catalog : NSObject{
    
    
    @public
    int page_count;
    NSString *text;
    int current_page;
    int catalog_id;
    NSString *total_size;
    NSDate *date;
    NSMutableArray* images;
    
    NSMutableArray* prev_images;
    NSMutableArray* imagesNames;
    NSMutableArray* loadingArray;
    
    DBController* DBC;
    NSArray* spis_tresci;
    UIImage* image_mini;
    
}
@property (nonatomic, retain) NSString *text, *ssid;
@property (nonatomic, retain) NSString *total_size;
@property (nonatomic, retain) NSMutableArray *images, *imagesNames, *loadingArray;
@property (nonatomic, retain) NSArray *spis_tresci;
@property (nonatomic,retain) DBController *DBC;
@property (nonatomic,retain) Ishue *ishue;

//- (id)initWithId:(int)catalog_id;

- (id)initWithIshueDatas:(Ishue*)ishue;

-(NSString*)przygotujPathDoPlikuZdjeciaCatalogu:(NSString*)filename;
-(NSString*)przygotujFileNameStrony:(int)strona_num;

-(void)przygotujSpisTresci;
-(int)getPageCount;
-(int)przygotujProcentPobranychPlikow;
-(int)getCurrentPage;
-(void)setCurrentPage:(int)_cp;
-(void)incCurrentPage;
-(void)decCurrentPage;
-(UIImage*)getCurrentImgFromPages;

-(NSString*)przygotujFileNameAktywnejStrony;
-(NSString*)przygotujPathDoPlikuZdjeciaCatalogu;
-(int)getPageNumFromFileName :(NSString*)filename;
-(NSString*)przygotujUrlDoPlikuZdjeciaCatalogu:(NSString*)filename;
-(UIImage*)przygotujImageAktywnejStrony;
@end
