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

@property (nonatomic) UIScrollView *fruitsInHandView;
@property (nonatomic) UIScrollView *fruitsAddView;

@property (nonatomic) NSMutableArray *allFruitsBasicInfo;
@property (nonatomic) NSArray *fruitsInHand;
@property (nonatomic) NSMutableArray *seasonalFruits;

@property (weak, nonatomic) IBOutlet UIButton *calendarButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (nonatomic) FruitItemDBHelper *dbHelper;
@property (nonatomic) NSString *dataBaseName;

@property (nonatomic) UIView *addFruitBottomView;

@property (nonatomic) UIFont *font;

@property (nonatomic) FruitTouchButton *addFruitButton;

@end

@implementation AddDeleteFruitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    // Set Font for the text
    self.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:16];
    
    // Get the screen resolution
    self.screenRect = [[UIScreen mainScreen] bounds];
    
    // Create settings button
    [self.settingsButton addTarget:self action:@selector(goToSettingsView:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create calendar button
    [self.calendarButton addTarget:self action:@selector(goToCalendarView:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view.backgroundColor = UIColorFromRGB(0xf4f4cd);
    
    // Create two subview, one for displaying fruits bought and one for displaying what fruits can be added.
    self.fruitsInHandView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, self.screenRect.size.width , self.screenRect.size.height / 2 - 30)];
    self.fruitsInHandView.backgroundColor = [UIColor colorWithRed:(CGFloat)173/255 green:(CGFloat)217/255 blue:(CGFloat)194/255 alpha:1];
    self.fruitsInHandView.contentSize = CGSizeMake(self.screenRect.size.width, self.screenRect.size.height);
    
    self.fruitsAddView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.screenRect.size.height / 2 + 30, self.screenRect.size.width , self.screenRect.size.height)];
    self.fruitsAddView.backgroundColor = [UIColor colorWithRed:(CGFloat)244/255 green:(CGFloat)244/255 blue:(CGFloat)205/255 alpha:1];
    
    // Initialize all fruits' basic information, like the seasonal property
    [self initAllFruitsBasicInfo];
    
    // Load seasonal fruits into the FruitsAddView
    [self loadFruitsAddViewWitnSeasonalFruits];
    
    // Initialize _DBHelper
    self.dbHelper = [[FruitItemDBHelper alloc] initDBHelper];
    self.dataBaseName = @"FRUITITEMINFO";
    
    // Load fruits user already bought into the FruitsInHandView
    [self loadFruitsInHandViewWitnFruitsInDB];
    
    // Set add fruit bottom view
    [self setAddFruitBottomView];
    
    [self.view addSubview:self.fruitsInHandView];
    [self.view addSubview:self.fruitsAddView];
}

- (void)setAddFruitBottomView {
    self.addFruitBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.screenRect.size.height / 2, self.screenRect.size.width, self.screenRect.size.height / 6)];
    self.addFruitBottomView.backgroundColor = [UIColor blackColor];
    
    UITextView *quantityText = [[UITextView alloc] init];
    quantityText.frame = CGRectMake(0, self.screenRect.size.height / 18, self.screenRect.size.width / 3, self.screenRect.size.height / 12);
    quantityText.text = @"Quantity";
    quantityText.textColor = [UIColor whiteColor];
    quantityText.font = self.font;
    quantityText.backgroundColor = self.addFruitBottomView.backgroundColor;
    quantityText.textAlignment = NSTextAlignmentCenter;
    
    [self.addFruitBottomView addSubview:quantityText];
    
    for (int i = 0; i < 3; i++) {
        UIButton *quantityButton = [[UIButton alloc] init];
        [quantityButton setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
        quantityButton.backgroundColor = [UIColor yellowColor];
        quantityButton.titleLabel.font = self.font;
        quantityButton.frame = CGRectMake(self.screenRect.size.width / 3 + i * self.screenRect.size.width / 5, self.screenRect.size.height / 16, self.screenRect.size.width / 6, self.screenRect.size.height / 12);
        [quantityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        quantityButton.tag = i;
        [quantityButton addTarget:self action:@selector(addFruitsToDatabaseWithQuantity:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.addFruitBottomView addSubview:quantityButton];
    }
    
    [self.fruitsAddView addSubview:self.addFruitBottomView];
}

-(void)goToSettingsView:(UIButton*)settingsButton {
    [self performSegueWithIdentifier:@"MovingToSettingsView" sender:settingsButton];
}

-(void)goToCalendarView:(UIButton*)calendarButton {
    [self performSegueWithIdentifier:@"MovingToCalendarView" sender:calendarButton];
}

-(void)addFruitsToDatabase:(FruitTouchButton*)inputFruit {
    NSLog(@"%@ is pressed in add view!", inputFruit.fruitItem.name);
    
    // Shift the current view up a little bit
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         self.fruitsAddView.frame = CGRectOffset(self.fruitsAddView.frame, 0, -self.screenRect.size.height / 6);
                     }
                     completion:nil];
    inputFruit.transform = CGAffineTransformMakeScale(1.2, 1.2);
    self.addFruitButton = inputFruit;
    
    /*
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
    [self loadFruitsInHandViewWitnFruitsInDB];*/
    
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
    [self loadFruitsInHandViewWitnFruitsInDB];
    
    // Shift the current view down back
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         self.fruitsAddView.frame = CGRectOffset(self.fruitsAddView.frame, 0, self.screenRect.size.height / 6);
                     }
                     completion:nil];
    self.addFruitButton.transform = CGAffineTransformMakeScale(1 / 1.2, 1 / 1.2);

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
