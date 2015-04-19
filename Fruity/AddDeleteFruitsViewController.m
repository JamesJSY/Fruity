//
//  AddDeleteFruitsViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "AddDeleteFruitsViewController.h"
#import "GlobalVariables.h"
#import "FruitItemBasicInfo.h"
#import "FruitTouchButton.h"
#import "FruitItemDBHelper.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AddDeleteFruitsViewController ()

@property GlobalVariables *globalVs;

@property (nonatomic) NSMutableArray *allFruitsBasicInfo;
@property (nonatomic) NSArray *fruitsInStorage;

@property (nonatomic) UIButton *calendarButton;
@property (nonatomic) UIButton *settingsButton;

@property (nonatomic) FruitItemDBHelper *dbHelper;
@property (nonatomic) NSString *dataBaseName;

@property (nonatomic) UIView *mainView;
@property (nonatomic) DisplaySeasonalFruitsScrollView *displaySeasonalFruitsView;
@property (nonatomic) AddFruitBottomView *addFruitBottomView;
@property (nonatomic) DisplayStorageBottomView *displayStorageBottomView;

@property (nonatomic) FruitTouchButton *addFruitButton;
@property (nonatomic) UIButton *eatButton;

@property (nonatomic) bool canScrollDown;
@property (nonatomic) bool isInAddingStatus;


@end

@implementation AddDeleteFruitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.globalVs = [GlobalVariables getInstance];
    
    // Initialize all fruits' basic information, like the seasonal property
    [self initAllFruitsBasicInfo];
    
    // Initialize _DBHelper
    self.dbHelper = [[FruitItemDBHelper alloc] initDBHelper];
    self.dataBaseName = @"FRUITITEMINFO";
    
    self.canScrollDown = NO;
    self.isInAddingStatus = NO;
    
    // Load all static subviews
    [self loadStaticSubviews];
    
    // Load the view that displays storage list at the bottom
    self.displayStorageBottomView = [[DisplayStorageBottomView alloc] initWithFrame:CGRectMake(0, self.globalVs.screenHeight, self.globalVs.screenWidth, self.globalVs.screenHeight)];
    self.displayStorageBottomView.superViewDelegate = self;
    [self.displayStorageBottomView loadDisplayStorageBottomView];
    [self.displayStorageBottomView setHidden:YES];
    [self.view addSubview:self.displayStorageBottomView];
    
    // Get the current month.
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:date];
    NSInteger month = [dateComponents month];
    
    // Load seasonal fruits to the middle of the mainView
    self.displaySeasonalFruitsView = [[DisplaySeasonalFruitsScrollView alloc] initWithFrame:CGRectMake(0, self.globalVs.screenHeight / 5, self.globalVs.screenWidth, self.globalVs.screenHeight * 3 / 5)];
    self.displaySeasonalFruitsView.superViewDelegate = self;
    [self.displaySeasonalFruitsView loadViewWithSeasonalFruitsBasicInfo:self.allFruitsBasicInfo withMonth:month];
    [self.mainView addSubview:self.displaySeasonalFruitsView];
    
    // Load bottom view that is in charge of the quantity of fruits added to the database
    self.addFruitBottomView = [[AddFruitBottomView alloc] initWithFrame:CGRectMake(0, self.globalVs.screenHeight, self.globalVs.screenWidth, self.globalVs.screenHeight / 6)];
    self.addFruitBottomView.superViewDelegate = self;
    [self.addFruitBottomView setHidden:YES];
    [self.mainView addSubview:self.addFruitBottomView];
    
    
    UITapGestureRecognizer *tapToAct = [[UITapGestureRecognizer alloc]
                                                           initWithTarget:self
                                                           action:@selector(gestureRecognition)];
    [self.mainView addGestureRecognizer:tapToAct];
}

-(void)goToSettingsView:(UIButton*)settingsButton {
    [self performSegueWithIdentifier:@"MovingToSettingsView" sender:settingsButton];
}

-(void)goToCalendarView:(UIButton*)calendarButton {
    [self performSegueWithIdentifier:@"MovingToCalendarView" sender:calendarButton];
}

- (void)loadStaticSubviews {
    // set up the main view
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.globalVs.screenWidth, self.globalVs.screenHeight)];
    self.mainView.backgroundColor = UIColorFromRGB(0xf4f4cd);
    [self.view addSubview:self.mainView];
    
    
    self.calendarButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 30, 30)];
    [self.calendarButton setImage:[UIImage imageNamed:@"icon-calendar.png"] forState:UIControlStateNormal];
    [self.calendarButton addTarget:self action:@selector(goToCalendarView:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:self.calendarButton];
    
    
    self.settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.globalVs.screenWidth - 40, 20, 30, 30)];
    [self.settingsButton setImage:[UIImage imageNamed:@"icon-timer.png"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(goToSettingsView:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:self.settingsButton];
    
    
    
    self.eatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.globalVs.screenWidth / 3, self.globalVs.screenWidth / 6)];
    self.eatButton.center = CGPointMake(self.globalVs.screenWidth / 2, self.globalVs.screenHeight - self.globalVs.screenWidth / 12);
    [self.eatButton setImage:[UIImage imageNamed:@"eat-button.png"] forState:UIControlStateNormal];
    [self.eatButton addTarget:self action:@selector(showStorageBottomView:) forControlEvents:UIControlEventTouchUpInside];
    [self.eatButton setTitle:@"EAT" forState:UIControlStateNormal];
    self.eatButton.titleLabel.font = self.globalVs.font;
    self.eatButton.titleLabel.textColor = UIColorFromRGB(0x676f6b);
    [self.eatButton setTitleEdgeInsets: UIEdgeInsetsMake(75,0,0,0)];
    [self.mainView addSubview:self.eatButton];
    
}


-(void)addFruitsToDatabase:(FruitTouchButton*)inputFruit {
    NSLog(@"%@ is pressed in add view!", inputFruit.fruitItem.name);
    self.isInAddingStatus = YES;
    
    [self.addFruitBottomView setHidden:NO];
    [self.eatButton setHidden:YES];
    
    self.mainView.backgroundColor = [self.mainView.backgroundColor colorWithAlphaComponent:0.3];
    [self.calendarButton setUserInteractionEnabled:NO];
    [self.calendarButton setAlpha:0.3];
    [self.settingsButton setUserInteractionEnabled:NO];
    [self.settingsButton setAlpha:0.3];
    [self.displaySeasonalFruitsView highlightOneFruitTouchButton:inputFruit];
    
    // Shift the current view up a little bit
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         self.addFruitBottomView.frame = CGRectOffset(self.addFruitBottomView.frame, 0, -self.globalVs.screenHeight / 6);
                     }
                     completion:nil];
    //inputFruit.transform = CGAffineTransformMakeScale(1.2, 1.2);
    self.addFruitButton = inputFruit;
    
}

-(void)addFruitsToDatabaseWithQuantity:(UIButton*)inputQuantityButton{
    
    // Get the current date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    // Prepare for the new item to be inserted into the database
    FruitItem *item = [[FruitItem alloc] init];
    item.name = self.addFruitButton.fruitItem.name;
    item.purchaseDate = [formatter stringFromDate:[NSDate date]];
    item.startStatus = 10;
    item.statusChangeThreshold = 1;
    item.isEaten = NO;
    
    for (int i = 0; i <inputQuantityButton.tag + 1; i++) {
        // Insert the new item into the database
        [self.dbHelper insertFruitItemIntoDB:item];
    }
    
    // Reload the view that displays fruits in storage
    [self.displayStorageBottomView loadDisplayStorageBottomView];
    
    // Shift the current view down back
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         self.addFruitBottomView.frame = CGRectOffset(self.addFruitBottomView.frame, 0, self.globalVs.screenHeight / 6);
                     }
                     completion:^(BOOL finished) {
                         //self.addFruitButton.transform = CGAffineTransformMakeScale(1 / 1.2, 1 / 1.2);
                         
                         self.isInAddingStatus = NO;
                         
                         self.mainView.backgroundColor = UIColorFromRGB(0xf4f4cd);
                         
                         
                         [self.calendarButton setUserInteractionEnabled:YES];
                         [self.calendarButton setAlpha:1];
                         [self.settingsButton setUserInteractionEnabled:YES];
                         [self.settingsButton setAlpha:1];
                         [self.displaySeasonalFruitsView deHighlightFruitTouchButton];
                         
                         [self.eatButton setHidden:NO];
                         [self.addFruitBottomView setHidden:YES];
                     }];

}

- (NSArray *) loadAllFruitsInStorageFromDB {
    NSString *query = [NSString stringWithFormat:(@"SELECT * FROM '%@'"), self.dataBaseName];
    self.fruitsInStorage = [[NSArray alloc] initWithArray:[self.dbHelper loadFruitItemsFromDB:query]];
    return self.fruitsInStorage;
}

- (void) deleteFruitItemWithID:(int) ID {
    [self.dbHelper deleteFruitItemsFromDB:ID];
}


- (void)showStorageBottomView:(UIButton *)eatButton {
    [self.displayStorageBottomView setHidden:NO];
    self.canScrollDown = YES;
    [self.eatButton setHidden:YES];
    [self.mainView bringSubviewToFront:self.eatButton];
    
    //[self.eatButton setUserInteractionEnabled:NO];
    [self.displaySeasonalFruitsView disableAllFruitTouchButtonsInteraction];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         self.mainView.frame = CGRectOffset(self.mainView.frame, 0, -self.globalVs.screenHeight / 4);
                         self.displayStorageBottomView.frame = CGRectOffset(self.displayStorageBottomView.frame, 0, -self.globalVs.screenHeight / 4);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)gestureRecognition {
    
    if (self.isInAddingStatus) {
        self.isInAddingStatus = NO;
        
        // Shift the current view down back
        [UIView animateWithDuration:0.3
                              delay:0
                            options:0
                         animations:^{
                             self.addFruitBottomView.frame = CGRectOffset(self.addFruitBottomView.frame, 0, self.globalVs.screenHeight / 6);
                         }
                         completion:^(BOOL finished) {
                             
                             self.mainView.backgroundColor = UIColorFromRGB(0xf4f4cd);
                             
                             [self.calendarButton setUserInteractionEnabled:YES];
                             [self.calendarButton setAlpha:1];
                             [self.settingsButton setUserInteractionEnabled:YES];
                             [self.settingsButton setAlpha:1];
                             
                             [self.displaySeasonalFruitsView deHighlightFruitTouchButton];
                             
                             [self.eatButton setHidden:NO];
                             [self.addFruitBottomView setHidden:YES];
                         }];
    }
    
    if (self.canScrollDown) {
        self.canScrollDown = NO;
        [UIView animateWithDuration:0.3
                              delay:0
                            options:0
                         animations:^{
                             self.mainView.frame = CGRectOffset(self.mainView.frame, 0, self.globalVs.screenHeight / 4);
                             self.displayStorageBottomView.frame = CGRectOffset(self.displayStorageBottomView.frame, 0, self.globalVs.screenHeight / 4);
                         }
                         completion:^(BOOL finished) {
                             [self.displayStorageBottomView setHidden:YES];
                             
                             [self.displaySeasonalFruitsView enableAllFruitTouchButtonsInteraction];
                             
                             [self.eatButton setHidden:NO];
                         }];
    }
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

/*
// We need to over-ride this method from UIViewController to provide a custom segue for unwinding
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    // Instantiate a new CustomUnwindSegue
    UnwindSegueGoToRight *segue = [[UnwindSegueGoToRight alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    return segue;
}*/

- (IBAction)unwindFromSettingsView:(UIStoryboardSegue *)segue {
}

- (IBAction)unwindFromCalendarView:(UIStoryboardSegue *)segue {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
