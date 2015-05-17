//
//  DisplayCalendarHistoryView.m
//  Fruity
//
//  Created by Shiyuan Jiang on 5/11/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "DisplayCalendarHistoryView.h"
#import "GlobalVariables.h"
#import "FruitTouchButton.h"

@interface DisplayCalendarHistoryView ()

@property GlobalVariables *globalVs;

@property (nonatomic) UILabel *monthLabel;
@property (nonatomic) UILabel *daysDidEatFruitLabel;
@property (nonatomic) UIButton *prevMonthButton;
@property (nonatomic) UIButton *nextMonthButton;

//@property (nonatomic) UIView *

@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UIView *historyView;

@property (nonatomic) float pixelsWidthForDisplayingItem;
@property (nonatomic) float itemDisplayRatio;
@property (nonatomic) int itemsPerRow;

@end

@implementation DisplayCalendarHistoryView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.globalVs = [GlobalVariables getInstance];
        
        self.backgroundColor = self.globalVs.blueColor;
        
        // Set the display mode
        self.pixelsWidthForDisplayingItem = self.frame.size.width / 4;
        self.itemDisplayRatio = (float) 1 / 2;
        self.itemsPerRow = 4;
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height / 5)];
        self.dateLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 9);
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.textColor = self.globalVs.darkGreyColor;
        self.dateLabel.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:30];
        //self.dateLabel.text = @"APR 28";
        [self addSubview:self.dateLabel];
        
        self.historyView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 6, self.frame.size.width, self.frame.size.height * 5 / 6)];
        self.historyView.backgroundColor = self.globalVs.softWhiteColor;
        self.historyView.clipsToBounds = YES;
        [self addSubview:self.historyView];
        
        // Set up tap gesture recognizer
        UITapGestureRecognizer *tapToAct = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(clickOnTheView)];
        //tapToAct.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapToAct];
    }
    return self;
}

- (void) reloadEatenFruitHistory {
    
    [[self.historyView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];

    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    
    NSString *monthText;
    switch (comps.month) {
        case 1:
            monthText = @"JAN";
            break;
        case 2:
            monthText = @"FEB";
            break;
        case 3:
            monthText = @"MAR";
            break;
        case 4:
            monthText = @"APR";
            break;
        case 5:
            monthText = @"MAY";
            break;
        case 6:
            monthText = @"JUN";
            break;
        case 7:
            monthText = @"JUL";
            break;
        case 8:
            monthText = @"AUG";
            break;
        case 9:
            monthText = @"SEPT";
            break;
        case 10:
            monthText = @"OCT";
            break;
        case 11:
            monthText = @"NOV";
            break;
        case 12:
            monthText = @"DEC";
            break;
        default:
            break;
    }
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %d", monthText, (int)comps.day];
    
    NSArray *fruitsEatenHistory = [[NSArray alloc] initWithArray:[self.globalVs.dbHelper loadAllFruitItemsEatenFromDBInYear:(int)comps.year month:(int)comps.month day:(int)comps.day]];
    
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
            
            fruitButton.frame = CGRectMake(20 + ([allFruitsButton count] % self.itemsPerRow) * self.pixelsWidthForDisplayingItem, 20 + ([allFruitsButton count] / self.itemsPerRow) * self.pixelsWidthForDisplayingItem, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
            
            [allFruitsButton addObject:fruitButton];
            [self.historyView addSubview:fruitButton];
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
        
        [self.historyView addSubview:quantityLabel];
    }

}

- (void) superViewDidShowBottomStorageView {
    self.historyView.layer.cornerRadius = 10;
}

- (void) clickOnTheView{
    self.historyView.layer.cornerRadius = 0;
    [self.delegate clickOnTheViewToQuitShowingStorageList];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
