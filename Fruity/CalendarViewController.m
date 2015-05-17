//
//  CalendarViewController.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/13/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "CalendarViewController.h"
#import "DisplayCalendarMonthView.h"
#import "GlobalVariables.h"
#import "FruitTouchButton.h"

@interface CalendarViewController ()

@property GlobalVariables *globalVs;
@property (nonatomic) NSMutableArray *allMonthViews;
@property (nonatomic) UIButton *bananaButton;
@property (nonatomic) UIButton *tipsButton;
@property (weak, nonatomic) UIButton *dayButton;

@property (nonatomic) UIScrollView *calendarView;
@property (nonatomic) UIScrollView *bottomScrollView;

@property (nonatomic) float pixelsWidthForDisplayingItem;
@property (nonatomic) float itemDisplayRatio;

@property (nonatomic) UIImageView *tutorialImageView;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.globalVs = [GlobalVariables getInstance];
    self.allMonthViews = [[NSMutableArray alloc] init];
    
    NSDate *date = [self.globalVs.userPreference valueForKey:@"FruityStartDate"];
    
    // Initialize the tips button
    self.tipsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.globalVs.screenWidth / 6, self.globalVs.screenWidth / 6)];
    self.tipsButton.center = CGPointMake(self.view.frame.size.width * 9 / 10, self.view.frame.size.width / 10);
    [self.tipsButton setImage:[UIImage imageNamed:@"hint.png"] forState:UIControlStateNormal];
    [self.tipsButton addTarget:self action:@selector(showHint) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tipsButton];
    
    // Set the display mode
    self.pixelsWidthForDisplayingItem = self.view.frame.size.width / 4;
    self.itemDisplayRatio = (float) 1 / 2;
    
    // Initialize the calendar view
    self.calendarView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, self.globalVs.screenWidth, self.globalVs.screenHeight * 5 / 6 - 60)];
    self.calendarView.contentSize = CGSizeMake(self.globalVs.screenWidth, self.globalVs.screenHeight);
    self.calendarView.scrollEnabled = YES;
    self.calendarView.backgroundColor = self.view.backgroundColor;
    
    // Initialize the bottom view
    self.bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.calendarView.frame.size.height + self.calendarView.frame.origin.y, self.globalVs.screenWidth, self.globalVs.screenHeight - (self.calendarView.frame.size.height + self.calendarView.frame.origin.y))];
    self.bottomScrollView.backgroundColor = self.globalVs.softWhiteColor;
    self.bottomScrollView.showsHorizontalScrollIndicator = NO;
    /*UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(bottomView.frame.size.width / 12, bottomView.frame.size.height / 8, bottomView.frame.size.width * 5 / 6, bottomView.frame.size.height / 4)];
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.numberOfLines = 0;
    textLabel.font = self.globalVs.font;
    textLabel.textColor = self.globalVs.darkGreyColor;
    textLabel.text = @"Congrats! You have eaten 15 bananas in this month.";
    
    self.bananaButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.globalVs.screenWidth / 8, self.globalVs.screenWidth / 8)];
    self.bananaButton.center = CGPointMake(self.globalVs.screenWidth - bottomView.frame.size.height  / 6, bottomView.frame.size.height * 5 / 6);
    self.bananaButton.userInteractionEnabled = NO;
    [self.bananaButton setImage:[UIImage imageNamed:@"banana_badge.png"] forState:UIControlStateNormal];
    [bottomView addSubview:self.bananaButton];
    [bottomView addSubview:textLabel];*/
    
    [self.view addSubview:self.bottomScrollView];
    [self.view addSubview:self.calendarView];
    
    
    int numberOfPastMonths = 0;
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *YearMonthDayCompsOfDate = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDateComponents *YearMonthDayCompsOfCurrentDate = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    NSDateComponents *oneMonthUnit = [NSDateComponents new];
    oneMonthUnit.month = 1;
    
    // Add past months to the month view
    while (YearMonthDayCompsOfDate.year <= YearMonthDayCompsOfCurrentDate.year
            && YearMonthDayCompsOfDate.month < YearMonthDayCompsOfCurrentDate.month) {
        DisplayCalendarMonthView *monthView = [[DisplayCalendarMonthView alloc] initWithFrame:CGRectMake(0, numberOfPastMonths * self.view.frame.size.height / 11, self.view.frame.size.width, self.view.frame.size.height * 5 / 11) date:date willDisplayDays:NO];
        monthView.delegate = self;
        [self.calendarView addSubview:monthView];
        
        // Add one month to the date
        date = [calendar dateByAddingComponents:oneMonthUnit toDate:date options:0];
        YearMonthDayCompsOfDate = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        
        // Add one to number of past months too
        numberOfPastMonths++;
        
        // Store the all month views for the purpose of changing frame size of certain month view according to the button inside
        [self.allMonthViews addObject:monthView];
    }
    
    // Expand the current month view to show fruit eating information on each day
    DisplayCalendarMonthView *currentMonthView = [[DisplayCalendarMonthView alloc] initWithFrame:CGRectMake(0, numberOfPastMonths * self.view.frame.size.height / 11, self.view.frame.size.width, self.view.frame.size.height * 5 / 11) date:date willDisplayDays:YES];
    currentMonthView.delegate = self;
    [self.calendarView addSubview:currentMonthView];
    [self.allMonthViews addObject:currentMonthView];
    
    // Resize the scroll view and set the offset so that the current month is at the beginning of the view
    self.calendarView.contentSize = CGSizeMake(self.globalVs.screenWidth, numberOfPastMonths * self.view.frame.size.height / 10 + self.view.frame.size.height * 5 / 12 + self.view.frame.size.height / 8);
    self.calendarView.contentOffset = CGPointMake(0, MAX(0, (numberOfPastMonths - 1) * self.view.frame.size.height / 10));
    
    // Initialize tutorial image view
    self.tutorialImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.globalVs.screenWidth, self.globalVs.screenHeight)];
    self.tutorialImageView.image = [UIImage imageNamed:@"instructions3.png"];
    UITapGestureRecognizer *tapToDismissTutorialGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                                             initWithTarget:self
                                                                             action:@selector(didTapToDismissTutorial)];
    self.tutorialImageView.userInteractionEnabled = YES;
    [self.tutorialImageView addGestureRecognizer:tapToDismissTutorialGestureRecognizer];
    if (![@"1" isEqualToString:[self.globalVs.userPreference valueForKey:@"isFirstOpenningCalendarView"]]) {
        [self.view addSubview:self.tutorialImageView];
    }
    
}

- (void)showHint {
    [self.view addSubview:self.tutorialImageView];
}

- (void)didTapToDismissTutorial {
    [self.globalVs.userPreference setValue:@"1" forKey:@"isFirstOpenningCalendarView"];
    [self.tutorialImageView removeFromSuperview];
}

- (void)reloadSuperViewWithChangeOfMonthView:(id)view willDisplayDays:(bool)isDisplayingDays; {
    float lastHeight = 0.0;
    for (DisplayCalendarMonthView *monthView in self.allMonthViews) {
        if (monthView == view) {
            // Resize the monthView frame size
            isDisplayingDays == NO ? [monthView setWillDisplayDaysToNO] : [monthView setWillDisplayDaysToYES];
            
            // Refocus the starting point of the scroll view
            self.calendarView.contentOffset = CGPointMake(0, lastHeight);
        }
        else {
            [monthView setWillDisplayDaysToNO];
        }
        monthView.frame = CGRectMake(0, lastHeight, monthView.frame.size.width, monthView.frame.size.height);
        lastHeight += monthView.frame.size.height;
    }
}

- (void)reloadSuperViewWithFruitsHistoryInDateComponent:(NSDateComponents *)dateComponent dayButtonClicked:(UIButton *)dayButton{
    
    [[self.bottomScrollView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    if (self.dayButton != nil) {
        self.dayButton.backgroundColor = [UIColor clearColor];
        self.dayButton.layer.cornerRadius = 0;
    }
    self.dayButton = dayButton;
    self.dayButton.layer.cornerRadius = self.dayButton.frame.size.width / 2;
    self.dayButton.backgroundColor = self.globalVs.softWhiteColor;
    
    NSArray *fruitsEatenHistory = [[NSArray alloc] initWithArray:[self.globalVs.dbHelper loadAllFruitItemsEatenFromDBInYear:(int)dateComponent.year month:(int)dateComponent.month day:(int)dateComponent.day]];
    
    NSMutableArray *allFruitsButton = [[NSMutableArray alloc] init];
    
    // Display all fruits user already bought
    for (int i = 0; i < [fruitsEatenHistory count]; i++) {
        FruitItem *item = fruitsEatenHistory[i];
        
        // Check if the item is in the previous list. If it is, then add one to the quantity. If it is not, create a new button
        bool isFound = false;
        for (FruitTouchButton *fruitButton in allFruitsButton) {
            if ([item.name isEqualToString:fruitButton.fruitItem.name]) {
                isFound = true;
                fruitButton.numberOfFruits++;
                break;
            }
        }
        
        if (!isFound) {
            FruitTouchButton *fruitButton = [[FruitTouchButton alloc] init];
            fruitButton.userInteractionEnabled = NO;
            
            NSString *imageFileName = [item.name stringByAppendingString:@".png"];
            [fruitButton setImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
            fruitButton.fruitItem = [[FruitItem alloc] initWithFruitItem:item];
            fruitButton.numberOfFruits = 1;
            fruitButton.tag = [allFruitsButton count];
            
            fruitButton.frame = CGRectMake(20 + [allFruitsButton count] * self.pixelsWidthForDisplayingItem, 20, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
            
            [allFruitsButton addObject:fruitButton];
            [self.bottomScrollView addSubview:fruitButton];
        }
    }
    
    for (FruitTouchButton *fruitButton in allFruitsButton) {
        UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pixelsWidthForDisplayingItem, 30)];
        quantityLabel.center = CGPointMake(fruitButton.center.x, fruitButton.center.y + self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
        quantityLabel.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:16];
        quantityLabel.textAlignment = NSTextAlignmentCenter;
        quantityLabel.textColor = self.globalVs.darkGreyColor;
        quantityLabel.tag = fruitButton.tag;
        
        if ([FruitItem isGroupFruitItem:fruitButton.fruitItem.name]) {
            quantityLabel.text = [NSString stringWithFormat:@"%d+", fruitButton.numberOfFruits * 10];
        }
        else {
            quantityLabel.text = [NSString stringWithFormat:@"%d", fruitButton.numberOfFruits];
        }
        
        [self.bottomScrollView addSubview:quantityLabel];
    }
    
    // Resize the scroll board size according to the item size
    self.bottomScrollView.contentSize = CGSizeMake(([allFruitsButton count] + 1) *self.pixelsWidthForDisplayingItem, self.bottomScrollView.frame.size.height);
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
