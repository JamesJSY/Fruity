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
#import "UnwindSegueGoToRight.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AddDeleteFruitsViewController ()

@property CGRect screenRect;

//@property (nonatomic) UIScrollView *fruitsInHandView;
//@property (nonatomic) UIScrollView *fruitsAddView;

@property (nonatomic) NSMutableArray *allFruitsBasicInfo;
@property (nonatomic) NSArray *fruitsInHand;
@property (nonatomic) NSMutableArray *seasonalFruits;

@property (nonatomic) NSMutableArray *allSeasonalFruitsButton;
@property (nonatomic) NSMutableArray *allStorageFruitsButton;

@property (nonatomic) UIButton *calendarButton;
@property (nonatomic) UIButton *settingsButton;

@property (nonatomic) UITextView *seasonalFruitTextView;
@property (nonatomic) UITextView *monthTextView;
@property (nonatomic) UIImageView *animationImageViewBottom;

@property (nonatomic) FruitItemDBHelper *dbHelper;
@property (nonatomic) NSString *dataBaseName;

@property (nonatomic) UIView *mainView;
@property (nonatomic) UIScrollView *AddSeasonalFruitView;
@property (nonatomic) UIView *addFruitBottomView;
@property (nonatomic) UIView *displayStorageBottomView;
@property (nonatomic) UIScrollView *storageListScrollView;

@property (nonatomic) UIFont *font;

@property (nonatomic) FruitTouchButton *addFruitButton;
@property (nonatomic) UIButton *eatButton;

@property (nonatomic) bool canScrollDown;
@property (nonatomic) bool isInAddingStatus;


@end

@implementation AddDeleteFruitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set Font for the text
    self.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:16];
    
    // Get the screen resolution
    self.screenRect = [[UIScreen mainScreen] bounds];
    
    // Initialize all fruits' basic information, like the seasonal property
    [self initAllFruitsBasicInfo];
    
    // Initialize _DBHelper
    self.dbHelper = [[FruitItemDBHelper alloc] initDBHelper];
    self.dataBaseName = @"FRUITITEMINFO";
    
    // Initialize two views at the bottom
    self.addFruitBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.screenRect.size.height, self.screenRect.size.width, self.screenRect.size.height / 6)];
    [self.addFruitBottomView setHidden:YES];
    self.displayStorageBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.screenRect.size.height, self.screenRect.size.width, self.screenRect.size.height)];
    self.displayStorageBottomView.backgroundColor = UIColorFromRGB(0xadd9c2);
    self.displayStorageBottomView.clipsToBounds = NO;
    [self.displayStorageBottomView setHidden:YES];
    
    self.storageListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, self.screenRect.size.width, self.screenRect.size.height / 3)];
    self.storageListScrollView.backgroundColor = [UIColor clearColor];
    self.storageListScrollView.clipsToBounds = NO;
    [self.displayStorageBottomView addSubview:self.storageListScrollView];
    
    self.allSeasonalFruitsButton = [[NSMutableArray alloc] init];
    self.allStorageFruitsButton = [[NSMutableArray alloc] init];
    self.canScrollDown = NO;
    self.isInAddingStatus = NO;
    
    // Initialize the animation image view
    self.animationImageViewBottom = [[UIImageView alloc] init];
    NSMutableArray *allChewingImages = [[NSMutableArray alloc] init];
    for (int i = 0; i < 8; i++) {
        [allChewingImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"monsterChew%d.png", i]]];
    }
    [self.animationImageViewBottom setAnimationImages:allChewingImages];
    [self.animationImageViewBottom setAnimationDuration:1.0];
    [self.animationImageViewBottom setAnimationRepeatCount:1];
    self.animationImageViewBottom.frame = CGRectMake(0, 0, self.screenRect.size.width / 3, self.screenRect.size.width / 3);
    self.animationImageViewBottom.center = CGPointMake(self.screenRect.size.width / 2, 0);
    
    [self.displayStorageBottomView addSubview:self.animationImageViewBottom];

    
    // Load all static subviews
    [self loadStaticSubviews];
    
    // Load add fruit bottom view
    [self loadAddFruitBottomView];
    
    // Load the view that displays storage list at the bottom
    [self loadDisplayStorageBottomView];
    
    [self.mainView addSubview:self.addFruitBottomView];
    [self.view addSubview:self.displayStorageBottomView];
    
    
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
    [self.seasonalFruitTextView setAlpha:0.3];
    [self.monthTextView setAlpha:0.3];
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:NO];
        if (self.allSeasonalFruitsButton[i] != inputFruit)
            [self.allSeasonalFruitsButton[i] setAlpha:0.3];
    }
    
    // Shift the current view up a little bit
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         self.addFruitBottomView.frame = CGRectOffset(self.addFruitBottomView.frame, 0, -self.screenRect.size.height / 6);
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
    
    // Reload fruitsInHandView
    [self loadDisplayStorageBottomView];
    
    // Shift the current view down back
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         self.addFruitBottomView.frame = CGRectOffset(self.addFruitBottomView.frame, 0, self.screenRect.size.height / 6);
                     }
                     completion:^(BOOL finished) {
                         //self.addFruitButton.transform = CGAffineTransformMakeScale(1 / 1.2, 1 / 1.2);
                         
                         self.isInAddingStatus = NO;
                         
                         self.mainView.backgroundColor = UIColorFromRGB(0xf4f4cd);
                         [self.seasonalFruitTextView setAlpha:1];
                         [self.monthTextView setAlpha:1];
                         
                         [self.calendarButton setUserInteractionEnabled:YES];
                         [self.calendarButton setAlpha:1];
                         [self.settingsButton setUserInteractionEnabled:YES];
                         [self.settingsButton setAlpha:1];
                         for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
                             [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:YES];
                             [self.allSeasonalFruitsButton[i] setAlpha:1];
                         }
                         
                         [self.eatButton setHidden:NO];
                         [self.addFruitBottomView setHidden:YES];
                     }];

}

- (void)dragFruitButton:(FruitTouchButton*)inputFruit withEvent:(UIEvent*) event{
    
    inputFruit.center = [[[event allTouches] anyObject] locationInView:self.storageListScrollView];
    
    /*
    // Start chewing animation
    [self.animationImageViewBottom startAnimating];
    
    // Delete the pressed item in the database
    [self.dbHelper deleteFruitItemsFromDB:inputFruit.fruitItem.ID];
    
    // Reload the view that display storage list
    [self loadDisplayStorageBottomView];*/
}

- (void)releaseFruitButton:(FruitTouchButton*)inputFruit withEvent:(UIEvent*) event{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.displayStorageBottomView];
    
    if ( CGRectContainsPoint(self.animationImageViewBottom.frame, point)) {
        // Start chewing animation
        [self.animationImageViewBottom startAnimating];
        
        // Delete the pressed item in the database
        [self.dbHelper deleteFruitItemsFromDB:inputFruit.fruitItem.ID];
        
        // Reload the view that display storage list
        [self loadDisplayStorageBottomView];
    }
    else {
        inputFruit.frame = CGRectMake((float)20 + inputFruit.tag * self.screenRect.size.width / 5, 30, (float) self.screenRect.size.width / 5 * 2 / 3, (float) self.screenRect.size.width / 5 * 2 / 3);
    }
}

- (void)loadStaticSubviews {
    //
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenRect.size.width, self.screenRect.size.height)];
    self.mainView.backgroundColor = UIColorFromRGB(0xf4f4cd);
    [self.view addSubview:self.mainView];
    
    
    self.calendarButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 30, 30)];
    [self.calendarButton setImage:[UIImage imageNamed:@"icon-calendar.png"] forState:UIControlStateNormal];
    [self.calendarButton addTarget:self action:@selector(goToCalendarView:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:self.calendarButton];
    
    
    self.settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.screenRect.size.width - 40, 20, 30, 30)];
    [self.settingsButton setImage:[UIImage imageNamed:@"icon-timer.png"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(goToSettingsView:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:self.settingsButton];
    
    

    self.eatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.screenRect.size.width / 3, self.screenRect.size.width / 6)];
    self.eatButton.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height - self.screenRect.size.width / 12);
    [self.eatButton setImage:[UIImage imageNamed:@"eat-button.png"] forState:UIControlStateNormal];
    [self.eatButton addTarget:self action:@selector(showStorageBottomView:) forControlEvents:UIControlEventTouchUpInside];
    [self.eatButton setTitle:@"EAT" forState:UIControlStateNormal];
    self.eatButton.titleLabel.font = self.font;
    self.eatButton.titleLabel.textColor = UIColorFromRGB(0x676f6b);
    [self.eatButton setTitleEdgeInsets: UIEdgeInsetsMake(75,0,0,0)];
    
    [self.mainView addSubview:self.eatButton];
    
    // Load seasonal fruits to the middle of the mainView;
    self.AddSeasonalFruitView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.screenRect.size.height / 5, self.screenRect.size.width, self.screenRect.size.height * 3 / 5)];
    [self loadFruitsAddViewWitnSeasonalFruits];
    [self.mainView addSubview:self.AddSeasonalFruitView];
}

- (void)showStorageBottomView:(UIButton *)eatButton {
    [self.displayStorageBottomView setHidden:NO];
    self.canScrollDown = YES;
    self.eatButton.frame = CGRectMake(0, 0, self.screenRect.size.width / 3, self.screenRect.size.width / 3);
    self.eatButton.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height);
    [self.eatButton setImage:[UIImage imageNamed:@"monsterChew0"] forState:UIControlStateNormal];
    [self.mainView bringSubviewToFront:self.eatButton];
    
    [self.eatButton setUserInteractionEnabled:NO];
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:NO];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         self.mainView.frame = CGRectOffset(self.mainView.frame, 0, -self.screenRect.size.height / 4);
                         self.displayStorageBottomView.frame = CGRectOffset(self.displayStorageBottomView.frame, 0, -self.screenRect.size.height / 4);
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
                             self.addFruitBottomView.frame = CGRectOffset(self.addFruitBottomView.frame, 0, self.screenRect.size.height / 6);
                         }
                         completion:^(BOOL finished) {
                             //self.addFruitButton.transform = CGAffineTransformMakeScale(1 / 1.2, 1 / 1.2);
                             
                             self.mainView.backgroundColor = UIColorFromRGB(0xf4f4cd);
                             [self.seasonalFruitTextView setAlpha:1];
                             [self.monthTextView setAlpha:1];
                             
                             [self.calendarButton setUserInteractionEnabled:YES];
                             [self.calendarButton setAlpha:1];
                             [self.settingsButton setUserInteractionEnabled:YES];
                             [self.settingsButton setAlpha:1];
                             for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
                                 [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:YES];
                                 [self.allSeasonalFruitsButton[i] setAlpha:1];
                             }
                             
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
                             self.mainView.frame = CGRectOffset(self.mainView.frame, 0, self.screenRect.size.height / 4);
                             self.displayStorageBottomView.frame = CGRectOffset(self.displayStorageBottomView.frame, 0, self.screenRect.size.height / 4);
                         }
                         completion:^(BOOL finished) {
                             [self.displayStorageBottomView setHidden:YES];
                             
                             for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
                                 [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:YES];
                             }
                             [self.eatButton setUserInteractionEnabled:YES];
                             
                             self.eatButton.frame = CGRectMake(0, 0, self.screenRect.size.width / 3, self.screenRect.size.width / 6);
                             self.eatButton.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height - self.screenRect.size.width / 12);
                             [self.eatButton setImage:[UIImage imageNamed:@"eat-button"] forState:UIControlStateNormal];
                         }];
    }
}

-(void)loadFruitsAddViewWitnSeasonalFruits {
    // Remove all subviews currently in the fruitsAddView
    [self.AddSeasonalFruitView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    // Reinitialize _seasonalFruits
    if (self.seasonalFruits != nil) {
        self.seasonalFruits = nil;
    }
    self.seasonalFruits = [[NSMutableArray alloc] init];
    
    /*
    // Set the display mode
    int itemsPerRow = 4;
    float pixelsWidthForDisplayingItem = (self.screenRect.size.width - 20) / itemsPerRow;
    float itemDisplayRatio = (float) 2 / 3;*/
    
    // Get the current month.
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:date];
    NSInteger month = [dateComponents month];
    
    self.seasonalFruitTextView = [[UITextView alloc] init];
    self.seasonalFruitTextView.text = @"Seasonal Fruits in";
    self.seasonalFruitTextView.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:14];
    self.seasonalFruitTextView.backgroundColor = [UIColor clearColor];
    self.seasonalFruitTextView.textColor = UIColorFromRGB(0xabacab);
    self.seasonalFruitTextView.frame = CGRectMake(0, 0, 110, 50);
    self.seasonalFruitTextView.textAlignment = NSTextAlignmentCenter;
    self.seasonalFruitTextView.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height / 2);
    [self.mainView addSubview:self.seasonalFruitTextView];
    
    self.monthTextView = [[UITextView alloc] init];
    self.monthTextView.text = @"April";
    self.monthTextView.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:22];
    self.monthTextView.backgroundColor = [UIColor clearColor];
    self.monthTextView.textColor = UIColorFromRGB(0x676f6b);
    self.monthTextView.textAlignment = NSTextAlignmentCenter;
    self.monthTextView.frame = CGRectMake(0, 0, 100, 50);
    self.monthTextView.textAlignment = NSTextAlignmentCenter;
    self.monthTextView.center = CGPointMake(self.screenRect.size.width / 2, self.screenRect.size.height / 2 + 40);
    [self.mainView addSubview:self.monthTextView];
    
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
            seasonalFruit.frame = CGRectMake(0, 0, self.screenRect.size.width / 7, self.screenRect.size.width / 7);
            
            [self.allSeasonalFruitsButton addObject:seasonalFruit];
            [self.AddSeasonalFruitView addSubview:seasonalFruit];
        }
    }
    
    double radius = (double) self.screenRect.size.width / 3;
    double degreePerButton = (double) 2 * M_PI / [self.allSeasonalFruitsButton count];
    
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        double degree = (double) degreePerButton * i;
        [self.allSeasonalFruitsButton[i] setCenter:CGPointMake(self.screenRect.size.width / 2 + radius * sin(degree), self.screenRect.size.height * 3 / 10 - radius * cos(degree))];
        
    }
}

- (void)loadAddFruitBottomView {
    self.addFruitBottomView.backgroundColor = [UIColor blackColor];

    UITextView *quantityText = [[UITextView alloc] init];
    quantityText.frame = CGRectMake(0, self.screenRect.size.height / 18, self.screenRect.size.width / 3, self.screenRect.size.height / 12);
    quantityText.text = @"Quantity";
    quantityText.textAlignment = NSTextAlignmentCenter;
    quantityText.textColor = UIColorFromRGB(0xabacab);
    quantityText.font = self.font;
    [quantityText setEditable:NO];
    quantityText.backgroundColor = [UIColor clearColor];
    
    [self.addFruitBottomView addSubview:quantityText];
    
    for (int i = 0; i < 3; i++) {
        UIButton *quantityButton = [[UIButton alloc] init];
        [quantityButton setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
        quantityButton.backgroundColor = self.addFruitBottomView.backgroundColor;
        quantityButton.titleLabel.font = self.font;
        quantityButton.tintColor = quantityText.textColor;
        quantityButton.frame = CGRectMake(self.screenRect.size.width / 3 + i * self.screenRect.size.width / 5, self.screenRect.size.height / 20, self.screenRect.size.width / 6, self.screenRect.size.height / 12);
        [quantityButton setTitleColor:UIColorFromRGB(0xabacab) forState:UIControlStateNormal];
        quantityButton.tag = i;
        [quantityButton addTarget:self action:@selector(addFruitsToDatabaseWithQuantity:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.addFruitBottomView addSubview:quantityButton];
    }
    
    [self.mainView addSubview:self.addFruitBottomView];
}

- (void)loadDisplayStorageBottomView {
    
    // Remove all subviews currently in the fruitsInHandView
    //[self.displayStorageBottomView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (int i = 0; i < [self.allStorageFruitsButton count]; i++) {
        [self.allStorageFruitsButton[i] removeFromSuperview];
    }
    
    // Reinitialize _fruitsInHand
    if (self.fruitsInHand != nil) {
        self.fruitsInHand = nil;
    }
    NSString *query = [NSString stringWithFormat:(@"SELECT * FROM '%@'"), self.dataBaseName];
    self.fruitsInHand = [[NSArray alloc] initWithArray:[self.dbHelper loadFruitItemsFromDB:query]];
    
    self.allStorageFruitsButton = nil;
    self.allStorageFruitsButton = [[NSMutableArray alloc] init];
    
    // Set the display mode
    float pixelsWidthForDisplayingItem = self.screenRect.size.width / 5;
    float itemDisplayRatio = (float) 2 / 3;
    
    // Display all fruits user already bought
    for (int i = 0; i < [self.fruitsInHand count]; i++) {
        FruitItem *item = self.fruitsInHand[i];
        
        FruitTouchButton *fruitInHand = [[FruitTouchButton alloc] init];
        [fruitInHand addTarget:self action:@selector(dragFruitButton:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [fruitInHand addTarget:self action:@selector(releaseFruitButton:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *imageFileName = [item.name stringByAppendingString:@".png"];
        [fruitInHand setImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
        fruitInHand.fruitItem = [[FruitItem alloc] initWithFruitItem:item];
        fruitInHand.tag = i;
        
        fruitInHand.frame = CGRectMake(20 + i * pixelsWidthForDisplayingItem, 30, pixelsWidthForDisplayingItem * itemDisplayRatio, pixelsWidthForDisplayingItem * itemDisplayRatio);
        
        [self.allStorageFruitsButton addObject:fruitInHand];
        [self.storageListScrollView addSubview:fruitInHand];
    }
    // Resize the scroll board size according to the item size
    self.storageListScrollView.contentSize = CGSizeMake(([self.fruitsInHand count] + 1) *pixelsWidthForDisplayingItem, self.screenRect.size.height / 6);

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
