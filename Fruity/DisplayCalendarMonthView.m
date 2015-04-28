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
        
        // Get the weekday of the first day in the current month
        NSCalendar *calendar = [NSCalendar currentCalendar];
        int daysPerWeek = 7;
        NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currDate];
        comps.day = 1;
        NSDate *firstDayOfMonth = [calendar dateFromComponents:comps];
        NSDateComponents *firstDayOfMonthComp = [calendar components:NSCalendarUnitWeekday fromDate:firstDayOfMonth];
        NSRange days = [calendar rangeOfUnit:NSCalendarUnitDay
                                      inUnit:NSCalendarUnitMonth
                                     forDate:firstDayOfMonth];
        // Weekday starts from Sunday
        int weekday = (int)firstDayOfMonthComp.weekday - 1;
        
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
        
        self.displayMonthButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 12, 0, self.frame.size.height / 6, self.frame.size.height / 6)];
        self.displayMonthButton.backgroundColor = self.globalVs.darkGreyColor;
        self.displayMonthButton.layer.cornerRadius = self.displayMonthButton.frame.size.width / 2;
        self.displayMonthButton.titleLabel.font = self.globalVs.font;
        self.displayMonthButton.titleLabel.textColor = self.globalVs.lightGreyColor;
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
            NSArray *eatFruitsArray = [self.globalVs.dbHelper loadAllFruitItemsEatenFromDBInYear:(int)comps.year month:(int)comps.month day:(int)comps.day + i];
            
            UILabel *day = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 6 + col * self.frame.size.width / 10, self.frame.size.height / 5 + row * self.frame.size.width / 10, self.frame.size.width / 10, self.frame.size.width / 10)];
            day.textAlignment = NSTextAlignmentCenter;
            day.text = [NSString stringWithFormat:@"%d", i + 1];
            day.clipsToBounds = YES;
            day.layer.cornerRadius = day.frame.size.width / 2;
            day.font = self.globalVs.font;
            if ((i + weekday) % daysPerWeek == 6 || (i + weekday) % daysPerWeek == 0) {
                day.textColor = self.globalVs.lightGreyColor;
            }
            else {
                day.textColor = self.globalVs.darkGreyColor;
            }
            if ([eatFruitsArray count] > 0) {
                day.backgroundColor = self.globalVs.softWhiteColor;
                daysDidEatFruit++;
            }
            if (!(comps.year < currentDateComps.year || comps.month < currentDateComps.month || comps.day + i <= currentDateComps.day)) {
                break;
            }
                
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
    if (self.willDisplayDays) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalFrameHeight / 5);
    }
    else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalFrameHeight);
    }
    self.willDisplayDays = !self.willDisplayDays;
    [self.delegate reloadSuperView:self];
}

- (void)setWillDisplayDaysToNO {
    self.willDisplayDays = NO;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalFrameHeight / 5);
}

- (void)setWillDisplayDaysToYES {
    self.willDisplayDays = YES;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.originalFrameHeight);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
