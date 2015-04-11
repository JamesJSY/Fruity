//
//  AddDeleteFruitsViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "AddDeleteFruitsViewController.h"
#import "FruitItemBasicInfo.h"
#import "FruitTouchButton.h"
#import "FruitItemDBHelper.h"

@interface AddDeleteFruitsViewController ()

@property CGRect screenRect;

@property UIScrollView *fruitsInHandView;
@property UIScrollView *fruitsAddView;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *calendarButton;

@property NSMutableArray *allFruitsBasicInfo;
@property NSArray *fruitsInHand;
@property NSMutableArray *seasonalFruits;

@property FruitItemDBHelper *dbHelper;
@property NSString *dataBaseName;

@end

@implementation AddDeleteFruitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get the screen resolution
    self.screenRect = [[UIScreen mainScreen] bounds];
    
    // Create settings button
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton addTarget:self action:@selector(goToSettingsView:) forControlEvents:UIControlEventTouchUpInside];
    self.settingsButton.frame = CGRectMake(self.screenRect.size.width - 30.0f, 20.0f, 20.0f, 20.0f);
    self.settingsButton.adjustsImageWhenHighlighted = false;
    [self.settingsButton setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.settingsButton];
    
    // Create calendar button
    self.calendarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.calendarButton addTarget:self action:@selector(goToCalendarView:) forControlEvents:UIControlEventTouchUpInside];
    self.calendarButton.frame = CGRectMake(10.0f, 20.0f, 20.0f, 20.0f);
    self.calendarButton.adjustsImageWhenHighlighted = false;
    [self.calendarButton setImage:[UIImage imageNamed:@"calendar.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.calendarButton];
    
    self.view.backgroundColor = [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)217/255 blue:(CGFloat)192/255 alpha:1];
    
    // Create two subview, one for displaying fruits bought and one for displaying what fruits can be added.
    self.fruitsInHandView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, self.screenRect.size.width , self.screenRect.size.height / 2 - 30)];
    self.fruitsInHandView.backgroundColor = [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)217/255 blue:(CGFloat)192/255 alpha:1];
    self.fruitsInHandView.contentSize = CGSizeMake(self.screenRect.size.width, self.screenRect.size.height);
    
    self.fruitsAddView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.screenRect.size.height / 2 + 30, self.screenRect.size.width , self.screenRect.size.height / 2 - 30)];
    self.fruitsAddView.backgroundColor = [UIColor colorWithRed:(CGFloat)244/255 green:(CGFloat)244/255 blue:(CGFloat)206/255 alpha:1];
    
    // Initialize all fruits' basic information, like the seasonal property
    [self initAllFruitsBasicInfo];
    
    // Load seasonal fruits into the FruitsAddView
    [self loadFruitsAddViewWitnSeasonalFruits];
    
    // Initialize _DBHelper
    self.dbHelper = [[FruitItemDBHelper alloc] initDBHelper];
    self.dataBaseName = @"FRUITITEMINFO";
    
    // Load fruits user already bought into the FruitsInHandView
    [self loadFruitsInHandViewWitnFruitsInDB];
    
    [self.view addSubview:self.fruitsInHandView];
    [self.view addSubview:self.fruitsAddView];
}

-(void)goToSettingsView:(UIButton*)settingsButton {
    
}

-(void)goToCalendarView:(UIButton*)calendarButton {
    
}

-(void)addFruitsToDatabase:(FruitTouchButton*)inputFruit {
    NSLog(@"%@ is pressed in add view!", inputFruit.fruitItem.name);
    
    // Get the current date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    // Prepare for the new item to be inserted into the database
    FruitItem *item = [[FruitItem alloc] init];
    item.name = inputFruit.fruitItem.name;
    item.purchaseDate = [formatter stringFromDate:[NSDate date]];
    item.startStatus = 10;
    item.statusChangeThreshold = 1;
    item.isEaten = NO;
    
    // Insert the new item into the database
    [self.dbHelper insertFruitItemIntoDB:item];
    
    // Reload fruitsInHandView
    [self loadFruitsInHandViewWitnFruitsInDB];
}

-(void)deleteFruitsToDatabase:(FruitTouchButton*)inputFruit {
    NSLog(@"%@ is pressed in delete view!", inputFruit.fruitItem.name);
    
    // Delete the pressed item in the database
    [self.dbHelper deleteFruitItemsFromDB:inputFruit.fruitItem.ID];
    
    // Reload fruitsInHandView
    [self loadFruitsInHandViewWitnFruitsInDB];
}

-(void)initAllFruitsBasicInfo {
    self.allFruitsBasicInfo = [[NSMutableArray alloc] init];
    
    FruitItemBasicInfo *apple= [[FruitItemBasicInfo alloc] init];
    apple.fruitName = @"apple";
    apple.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], nil];
    [self.allFruitsBasicInfo addObject:apple];
    
    FruitItemBasicInfo *apricot= [[FruitItemBasicInfo alloc] init];
    apricot.fruitName = @"apricot";
    apricot.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], nil];
    [self.allFruitsBasicInfo addObject:apricot];
    
    FruitItemBasicInfo *avocado= [[FruitItemBasicInfo alloc] init];
    avocado.fruitName = @"avocado";
    avocado.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], nil];
    [self.allFruitsBasicInfo addObject:avocado];
    
    FruitItemBasicInfo *blackberry= [[FruitItemBasicInfo alloc] init];
    blackberry.fruitName = @"blackberry";
    blackberry.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], nil];
    [self.allFruitsBasicInfo addObject:blackberry];
    
    FruitItemBasicInfo *banana= [[FruitItemBasicInfo alloc] init];
    banana.fruitName = @"banana";
    banana.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], [NSNumber numberWithInt:12], nil];
    [self.allFruitsBasicInfo addObject:banana];
    
    FruitItemBasicInfo *blueberry= [[FruitItemBasicInfo alloc] init];
    blueberry.fruitName = @"blueberry";
    blueberry.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], nil];
    [self.allFruitsBasicInfo addObject:blueberry];
    
    FruitItemBasicInfo *boysenberry= [[FruitItemBasicInfo alloc] init];
    boysenberry.fruitName = @"boysenberry";
    boysenberry.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:6], nil];
    [self.allFruitsBasicInfo addObject:boysenberry];
    
    FruitItemBasicInfo *cherry= [[FruitItemBasicInfo alloc] init];
    cherry.fruitName = @"cherry";
    cherry.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], nil];
    [self.allFruitsBasicInfo addObject:cherry];
    
    FruitItemBasicInfo *fig= [[FruitItemBasicInfo alloc] init];
    fig.fruitName = @"fig";
    fig.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], nil];
    [self.allFruitsBasicInfo addObject:fig];
    
    FruitItemBasicInfo *grapefruit= [[FruitItemBasicInfo alloc] init];
    grapefruit.fruitName = @"grapefruit";
    grapefruit.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:12], nil];
    [self.allFruitsBasicInfo addObject:grapefruit];
    
    FruitItemBasicInfo *grape= [[FruitItemBasicInfo alloc] init];
    grape.fruitName = @"grape";
    grape.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], nil];
    [self.allFruitsBasicInfo addObject:grape];
    
    FruitItemBasicInfo *guava= [[FruitItemBasicInfo alloc] init];
    guava.fruitName = @"guava";
    guava.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], [NSNumber numberWithInt:12], nil];
    [self.allFruitsBasicInfo addObject:guava];
    
    FruitItemBasicInfo *kiwi= [[FruitItemBasicInfo alloc] init];
    kiwi.fruitName = @"kiwi";
    kiwi.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], [NSNumber numberWithInt:12], nil];
    [self.allFruitsBasicInfo addObject:kiwi];
    
    FruitItemBasicInfo *lemon= [[FruitItemBasicInfo alloc] init];
    lemon.fruitName = @"lemon";
    lemon.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], [NSNumber numberWithInt:12], nil];
    [self.allFruitsBasicInfo addObject:lemon];
    
    FruitItemBasicInfo *lime= [[FruitItemBasicInfo alloc] init];
    lime.fruitName = @"lime";
    lime.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], [NSNumber numberWithInt:12], nil];
    [self.allFruitsBasicInfo addObject:lime];
    
    FruitItemBasicInfo *melon= [[FruitItemBasicInfo alloc] init];
    melon.fruitName = @"melon";
    melon.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], nil];
    [self.allFruitsBasicInfo addObject:melon];
    
    FruitItemBasicInfo *nectarine= [[FruitItemBasicInfo alloc] init];
    nectarine.fruitName = @"nectarine";
    nectarine.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], nil];
    [self.allFruitsBasicInfo addObject:nectarine];
    
    FruitItemBasicInfo *orange= [[FruitItemBasicInfo alloc] init];
    orange.fruitName = @"orange";
    orange.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], [NSNumber numberWithInt:12], nil];
    [self.allFruitsBasicInfo addObject:orange];
    
    FruitItemBasicInfo *peach= [[FruitItemBasicInfo alloc] init];
    peach.fruitName = @"peach";
    peach.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], nil];
    [self.allFruitsBasicInfo addObject:peach];
    
    FruitItemBasicInfo *pear= [[FruitItemBasicInfo alloc] init];
    pear.fruitName = @"pear";
    pear.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], nil];
    [self.allFruitsBasicInfo addObject:pear];
    
    FruitItemBasicInfo *plum= [[FruitItemBasicInfo alloc] init];
    plum.fruitName = @"plum";
    plum.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], nil];
    [self.allFruitsBasicInfo addObject:plum];
    
    FruitItemBasicInfo *pomegranate= [[FruitItemBasicInfo alloc] init];
    pomegranate.fruitName = @"pomegranate";
    pomegranate.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], [NSNumber numberWithInt:12], nil];
    [self.allFruitsBasicInfo addObject:pomegranate];
    
    FruitItemBasicInfo *raspberry= [[FruitItemBasicInfo alloc] init];
    raspberry.fruitName = @"raspberry";
    raspberry.seasons = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], [NSNumber numberWithInt:11], nil];
    [self.allFruitsBasicInfo addObject:raspberry];
    
    FruitItemBasicInfo *strawberry= [[FruitItemBasicInfo alloc] init];
    strawberry.fruitName = @"strawberry";
    strawberry.seasons = [[NSArray alloc] initWithObjects: [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10], nil];
    [self.allFruitsBasicInfo addObject:strawberry];

}

-(void)loadFruitsAddViewWitnSeasonalFruits {
    // Remove all subviews currently in the fruitsAddView
    [self.fruitsAddView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    // Reinitialize _seasonalFruits
    if (self.seasonalFruits != nil) {
        self.seasonalFruits = nil;
    }
    self.seasonalFruits = [[NSMutableArray alloc] init];
    
    // Set the display mode
    int itemsPerRow = 4;
    float pixelsWidthForDisplayingItem = (self.screenRect.size.width - 20) / itemsPerRow;
    float itemDisplayRatio = (float) 2 / 3;
    
    // Get the current month.
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:date];
    NSInteger month = [dateComponents month];
    
    // Compute what seasonal fruits are in the current month.
    for (int i = 0; i < [self.allFruitsBasicInfo count]; i++) {
        bool isInSeason = false;
        FruitItemBasicInfo *item = self.allFruitsBasicInfo[i];
        for (int j = 0; j < [item.seasons count]; j++) {
            if ([item.seasons[j] integerValue] == month) {
                [self.seasonalFruits addObject:item.fruitName];
                isInSeason = true;
                break;
            }
        }
        
        if (isInSeason) {
            // Add the corresponding fruit to the fruitsAddView
            FruitTouchButton *seasonalFruit = [[FruitTouchButton alloc] init];
            [seasonalFruit addTarget:self action:@selector(addFruitsToDatabase:) forControlEvents:UIControlEventTouchUpInside];
            NSString *imageFileName = [item.fruitName stringByAppendingString:@".png"];
            [seasonalFruit setImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
            seasonalFruit.fruitItem = [[FruitItem alloc] init];
            seasonalFruit.fruitItem.name = [[NSString alloc] initWithString:item.fruitName];
        
            int row = (int)([self.seasonalFruits count] - 1) / itemsPerRow;
            int column = (int)([self.seasonalFruits count] - 1) % itemsPerRow;
            seasonalFruit.frame = CGRectMake(20 + column * pixelsWidthForDisplayingItem, 20 + row * pixelsWidthForDisplayingItem, pixelsWidthForDisplayingItem * itemDisplayRatio, pixelsWidthForDisplayingItem * itemDisplayRatio);
            [self.fruitsAddView addSubview:seasonalFruit];
        }
    }
    
    // Resize the scroll board size according to the item size
    self.fruitsAddView.contentSize = CGSizeMake(self.screenRect.size.width, self.seasonalFruits.count / itemsPerRow * pixelsWidthForDisplayingItem + 90);
}

-(void)loadFruitsInHandViewWitnFruitsInDB {
    // Remove all subviews currently in the fruitsInHandView
    [self.fruitsInHandView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    // Reinitialize _fruitsInHand
    if (self.fruitsInHand != nil) {
        self.fruitsInHand = nil;
    }
    NSString *query = [NSString stringWithFormat:(@"SELECT * FROM '%@'"), self.dataBaseName];
    self.fruitsInHand = [[NSArray alloc] initWithArray:[self.dbHelper loadFruitItemsFromDB:query]];
    
    // Set the display mode
    int itemsPerRow = 4;
    float pixelsWidthForDisplayingItem = (self.screenRect.size.width - 20) / itemsPerRow;
    float itemDisplayRatio = (float) 2 / 3;
    
    // Display all fruits user already bought
    for (int i = 0; i < [self.fruitsInHand count]; i++) {
        FruitItem *item = self.fruitsInHand[i];
        
        FruitTouchButton *fruitInHand = [[FruitTouchButton alloc] init];
        [fruitInHand addTarget:self action:@selector(deleteFruitsToDatabase:) forControlEvents:UIControlEventTouchUpInside];
        NSString *imageFileName = [item.name stringByAppendingString:@".png"];
        [fruitInHand setImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
        fruitInHand.fruitItem = [[FruitItem alloc] initWithFruitItem:item];
        
        int row = (int)(i - 1) / itemsPerRow;
        int column = (int)(i - 1) % itemsPerRow;
        fruitInHand.frame = CGRectMake(20 + column * pixelsWidthForDisplayingItem, 20 + row * pixelsWidthForDisplayingItem, pixelsWidthForDisplayingItem * itemDisplayRatio, pixelsWidthForDisplayingItem * itemDisplayRatio);
        [self.fruitsInHandView addSubview:fruitInHand];
    }
    
    // Resize the scroll board size according to the item size
    self.fruitsInHandView.contentSize = CGSizeMake(self.screenRect.size.width, self.fruitsInHand.count / itemsPerRow * pixelsWidthForDisplayingItem + 90);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
