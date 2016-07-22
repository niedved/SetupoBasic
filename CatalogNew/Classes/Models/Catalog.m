

#import "Catalog.h"



@implementation Catalog
@synthesize text, ssid, loadingArray, total_size, imagesNames, images, DBC, spis_tresci;


-(int)przygotujProcentPobranychPlikow
{
    int not_downloaded = 0;
    for ( NSString *imgName in imagesNames ){
        if ( [imgName isEqual:@"loading960_0.png"] ){
            not_downloaded++;
        }
         
    }
    
    int downladed = (page_count - not_downloaded);
    double proc = ((double)downladed / (double)(page_count-1) )*100;
    int procent = (int)proc;
    if ( procent < 0 ) { procent = 0; };
    return procent;
}



-(void)prepareLoadingArray{
    loadingArray = [[NSMutableArray alloc] initWithCapacity:6];
    [loadingArray addObject:@"loading960_0.png"];
    [loadingArray addObject:@"loading960_0.png"];
    [loadingArray addObject:@"loading960_0.png"];
    [loadingArray addObject:@"loading960_0.png"];
    [loadingArray addObject:@"loading960_0.png"];
    [loadingArray addObject:@"loading960_0.png"];
}

- (id)initWithIshueDatas:(Ishue*)ishue{
    self.ishue = ishue;
    self = [super init];
    if (self){
        
        catalog_id = ishue->ishue_id;
        page_count = ishue->pagesNum;
        total_size = @"12.05";
        
        images = [[NSMutableArray alloc] initWithCapacity:page_count];
        imagesNames = [[NSMutableArray alloc] initWithCapacity:page_count];
        
        [self prepareLoadingArray];
        UIImage* loading = [UIImage imageNamed:[loadingArray objectAtIndex:0]];
        
        for (int i=0; i<[ishue.pages count]; i++) {
            
            NSString* path = [self przygotujPathDoPlikuZdjeciaCatalogu:
                              [NSString stringWithFormat:@"thumb_%d_%d.jpg", catalog_id, i+1 ]];

            if ( ![[NSFileManager defaultManager] fileExistsAtPath: path]  ){
                [images addObject:loading];
                [imagesNames addObject:[loadingArray objectAtIndex:0]];
            }
            else{
                [images addObject:[UIImage imageWithContentsOfFile:path]];
                [imagesNames addObject:path];
            }
            
        }
        
        current_page = 0;
        
        
    }//endif self
    
    return self;
}



-(void)przygotujSpisTresci{
    if ( [spis_tresci count] == 0 ){
        DBC = [[DBController alloc] init];
//        spis_tresci = [[DBC getKatalogSpis:catalog_id] copy];
    }
}


-(NSString*)przygotujPathDoPlikuZdjeciaCatalogu:(NSString*)filename
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
    return filePath;
}


-(NSString*)przygotujUrlDoPlikuZdjeciaCatalogu:(NSString*)filename
{
    NSLog(@"przygotujUrlDoPlikuZdjeciaCatalogu: %@", filename );
    return [NSString stringWithFormat:@"%@/Resources/pages/%d/%@", STAGING_URL_NOINDEX,catalog_id, filename];
}


-(NSString*)przygotujFileNameStrony :(int)strona_num
{
    NSString* filename = [NSString stringWithFormat:@"thumb_%d_%d.jpg", self.ishue->ishue_id, strona_num];
    NSLog(@"filename: %@", filename);
    return filename;
}

-(NSString*)przygotujFileNameAktywnejStrony
{
    NSString* filename = [NSString stringWithFormat:@"thumb_%d_%d.jpg",  self.ishue->ishue_id, current_page+1];
    NSLog(@"filename: %@", filename);
    return filename;
}

-(NSString*)przygotujPathDoPlikuZdjeciaCatalogu
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, [self przygotujFileNameAktywnejStrony]];
}
-(UIImage*)przygotujImageAktywnejStrony
{
    return [images objectAtIndex:current_page];
}

-(int)getPageNumFromFileName:(NSString*)filename
{
    int pageNum = 0;
    for (NSString* page in self.ishue.pagesPrevs ) {
        
        NSArray* array2 = [filename componentsSeparatedByString:@"/"];
        
        NSArray* array2ask = [[array2 lastObject] componentsSeparatedByString:@"?"];
                if ([[array2ask firstObject] isEqualToString:page] ){
            return pageNum;
        }
        pageNum++;
        
    }
    
    return 0;
//    
//    NSArray* array1 = [filename componentsSeparatedByString:@"."];
//    NSString* string1 = [array1 objectAtIndex:([array1 count]-2)];
//    NSArray* array2 = [string1 componentsSeparatedByString:@"_"];
//    return [[array2 objectAtIndex:([array2 count]-1)] intValue] ;
}

-(int)getPageCount{
    return page_count;
}
-(int)getCurrentPage{
    return current_page;
}
-(void)setCurrentPage :(int)_cp{
    current_page = _cp;
}

-(UIImage*)getCurrentImgFromPages{
    NSLog(@"getCurrentImgFromPages: %d ", current_page);
    return [images objectAtIndex:current_page];
}

-(void)incCurrentPage{
    if (current_page <  page_count ){ 
        current_page ++;
    }
}
-(void)decCurrentPage{
    current_page --;
}





@end
