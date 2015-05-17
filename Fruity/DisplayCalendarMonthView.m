//
//  DisplayCalendarMonthView.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/27/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "DisplayCalendarMonthView.h"
#import "GlobalVariables.h"
#import "FruitItemDBHelper.h"

@interface DisplayCalendarMonthView ()

@property GlobalVariables *globalVs;

@property (nonatomic) UIButton *displayMonthButton;
@property (nonatomic) UILabel *displayDaysDidEatFruitLabel;

@property (nonatomic) NSMutableArray *allDayButtons;

@property (nonatomic) NSDateComponents *dateComponents;
@property (nonatomic) bool willDisplayDays;
@property (nonatomic) float originalFrameHeight;

@end

@implementation DisplayCalendarMonthView

- (instancetype) initWithFrame:(CGRect)frame date:(NSDate*)currDate willDisplayDays:(bool)willDisplayDays{
    self = [super initWithFrame:frame];
    if (self) {
        self.globalVs = [GlobalVariables getInstance];
        self.willDisplayDays = willDisplayDays;
        self.clipsToBounds = YES;
        self.originalFrameHeight = self.frame.size.height;
        
        self.allDayButtons = [[NSMutableArray alloc] init];
        
        // Get the weekday of the first day in the current month
        NSCalendar *calendar = [NSCalendar currentCalendar];
        int daysPerWeek = 7;
        self.dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currDate];
        self.dateComponents.day = 1;
        NSDate *firstDayOfMonth = [calendar dateFromComponents:self.dateComponents];
        NSDateComponents *firstDayOfMonthComp = [calendar components:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
        NSRange days = [calendar rangeOfUnit:NSCalendarUnitDay
                                      inUnit:NSCalendarUnitMonth
                                     forDate:firstDayOfMonth];
        // Weekday starts from Sunday
        int weekday = (int)firstDayOfMonthComp.weekday - 1;
        
        NSString *monthText;
        switch (self.dateComponents.month) {
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
        
        self.displayMonthButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 12, 0, self.frame.size.height / 6, self.frame.size.height / 6)];
        self.displayMonthButton.backgroundColor = self.globalVs.darkGreyColor;
        self.displayMonthButton.layer.cornerRadius = self.displayMonthButton.frame.size.width / 2;
        self.displayMonthButton.titleLabel.font = self.globalVs.font;
        self.displayMonthButton.titleLabel.textColor = self.globalVs.softWhiteColor;
        [self.displayMonthButton setTitle:monthText forState:UIControlStateNormal];
        [self.displayMonthButton addTarget:self action:@selector(monthButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.displayMonthButton];
        
        // Set up line view
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.displayMonthButton.center.x, self.displayMonthButton.center.y + self.displayMonthButton.frame.size.height / 2, 1, self.frame.size.height)];
        lineView.backgroundColor = self.globalVs.darkGreyColor;
        [self addSubview:lineView];
        
        
        self.displayDaysDidEatFruitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 4, 30)];
        self.displayDaysDidEatFruitLabel.center = CGPointMake(self.displayMonthButton.center.x + self.frame.size.width / 4, self.displayMonthButton.center.y);
        self.displayDaysDidEatFruitLabel.font = self.globalVs.font;
        self.displayDaysDidEatFruitLabel.textColor = self.globalVs.darkGreyColor;
        [self addSubview:self.displayDaysDidEatFruitLabel];
        
        // Get current date so that no days after today will be displayed
        NSDateComponents *currentDateComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        
        int daysDidEatFruit = 0;
        // Show each day of the month one by one
        for (int i = 0; i < days.length; i++) {
            int row = (i + weekday) / daysPerWeek;
            int col = (i + weekday) % daysPerWeek;
            NSArray *eatFruitsArray = [self.globalVs.dbHelper loadAllFruitItemsEatenFromDBInYear:(int)self.dateComponents.year month:(int)self.dateComponents.month day:(int)self.dateComponents.day + i];
            
            UIButton *day = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 6 + col * self.frame.size.width / 9, self.frame.size.height / 5 + row * self.frame.size.width / 9, self.frame.size.width / 11, self.frame.size.width / 11)];
            day.titleLabel.textAlignment = NSTextAlignmentCenter;
            [day setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
            day.clipsToBounds = NO;
            //day.layer.cornerRadius = day.frame.size.width / 2;
            day.titleLabel.font = self.globalVs.font;
            day.tag = i;
            
            if ((i + weekday) % daysPerWeek == 6 || (i + weekday) % daysPerWeek == 0) {
                [day setTitleColor:self.globalVs.lightGreyColor forState:UIControlStateNormal];
            }
            else {
                [day setTitleColor:self.globalVs.darkGreyColor forState:UIControlStateNormal];
            }
            
            // Users can only click on days that has eaten history
            if ([eatFruitsArray count] > 0) {
                int radius = day.frame.size.height / 2;
                CAShapeLayer *circle = [CAShapeLayer layer];
                // Make a circular shape
                circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                                         cornerRadius:radius].CGPath;
                
                // Configure the apperence of the circle
                circle.fillColor = [UIColor clearColor].CGColor;
                circle.strokeColor = self.globalVs.softWhiteColor.CGColor;
                circle.lineWidth = 2;
                [day.layer addSublayer:circle];
                
                //day.backgroundColor = self.globalVs.softWhiteColor;
                [day addTarget:self action:@selector(dayButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
                daysDidEatFruit++;
            }
            else {
                day.userInteractionEnabled = NO;
            }
            
            if (!(self.dateComponents.year < currentDateComps.year || self.dateComponents.month < currentDateComps.month || self.dateComponents.day + i <= currentDateComps.day)) {
                break;
            }
            
            [self.allDayButtons addObject:day];
            [self addSubview:day];
        }
        
        // Set the displayDaysDidEatFruitLabel to the number of days that the user have eaten fruits
        self.displayDaysDidEatFruitLabel.text = [NSString stringWithFormat:@"%d/%lu", daysDidEatFruit, (unsigned long)days.length ];
        // Reset the color of the days in the label on which users have eaten fruits
        NSMutableAttributedString *text =
        [[NSMutableAttributedString alloc]
         initWithAttributedString: self.displayDaysDidEatFruitLabel.attributedText];
        
        [text addAttribute:NSForegroundColorAttributeName
                     value:self.globalVs.softWhiteColor
                     range:NSMakeRange(0, daysDidEatFruit < 10 ? 1 : 2)];
        [self.displayDaysDidEatFruitLabel setAttributedText: text];

        // Check whether to display all days information in the month
        if (!self.willDisplayDays) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalFrameHeight / 5);
        }
        else {
            lineView.hidden = YES;
        }
    }
    return self;
}

- (void)monthButtonDidPress:(UIButton*) monthButton {
    self.willDisplayDays = !self.willDisplayDays;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         if (self.willDisplayDays) {
                             self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalFrameHeight);
                         }
                         else {
                             self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalFrameHeight / 5);
                         }
                         [self.delegate reloadSuperViewWithChangeOfMonthView:self willDisplayDays:self.willDisplayDays];
                     }
                     completion:^(BOOL finished) {
    
                     }];
    
    
}

- (void)setWillDisplayDaysToNO {
    self.willDisplayDays = NO;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalFrameHeight / 5);
}

- (void)setWillDisplayDaysToYES {
    self.willDisplayDays = YES;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalFrameHeight);
}

- (void)dayButtonDidClick:(UIButton*)dayButton {
    NSLog(@"Day %d is clicked in the calendar view.", ((int)dayButton.tag) + 1);
    
    // Create a date component have the same date as the date clicked
    NSDateComponents *currDateComponents = [[NSDateComponents alloc] init];
    currDateComponents.year = self.dateComponents.year;
    currDateComponents.month = self.dateComponents.month;
    currDateComponents.day = dayButton.tag + 1;
    
    // Reload superview's fruit history display
    [self.delegate reloadSuperViewWithFruitsHistoryInDateComponent:currDateComponents dayButtonClicked:dayButton];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
