//
//  DisplaySeasonalFruitsScrollView.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "DisplaySeasonalFruitsScrollView.h"
#import "GlobalVariables.h"
#import "FruitItemBasicInfo.h"

@interface DisplaySeasonalFruitsScrollView ()

@property GlobalVariables *globalVs;

@property NSMutableArray *seasonalFruits;

@property UILabel *seasonalFruitLabel;
@property UILabel *monthLabel;

@property NSMutableArray *allSeasonalFruitsButton;
@property NSMutableArray *allFruitsBasicInfo;

@end

@implementation DisplaySeasonalFruitsScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.globalVs = [GlobalVariables getInstance];
        self.seasonalFruitLabel = [[UILabel alloc] init];
        self.monthLabel = [[UILabel alloc] init];
        
        // Set up the two textViews in the middle
        self.seasonalFruitLabel.text = @"Seasonal Fruits in";
        self.seasonalFruitLabel.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:14];
        self.seasonalFruitLabel.backgroundColor = [UIColor clearColor];
        self.seasonalFruitLabel.textColor = self.globalVs.lightGreyColor;
        self.seasonalFruitLabel.frame = CGRectMake(0, 0, 110, 50);
        self.seasonalFruitLabel.textAlignment = NSTextAlignmentCenter;
        self.seasonalFruitLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 20);
        [self addSubview:self.seasonalFruitLabel];
        
        self.monthLabel.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:40];
        self.monthLabel.backgroundColor = [UIColor clearColor];
        self.monthLabel.textColor = self.globalVs.darkGreyColor;
        self.monthLabel.textAlignment = NSTextAlignmentCenter;
        self.monthLabel.frame = CGRectMake(0, 0, 100, 50);
        self.monthLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 20);
        [self addSubview:self.monthLabel];
        
        }
    return (self);
}

- (void)loadViewWithSeasonalFruitsBasicInfo:(NSMutableArray *)allFruitsBasicInfo withMonth:(int) month{
    self.monthForDisplaying = month;
    self.allFruitsBasicInfo = allFruitsBasicInfo;
    
    // Remove all subviews currently in the fruitsAddView
    [self.allSeasonalFruitsButton makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    // Reinitialize seasonal fruits and related buttons
    self.seasonalFruits = [[NSMutableArray alloc] init];
    self.allSeasonalFruitsButton = [[NSMutableArray alloc] init];

    switch (month) {
        case 1:
            self.monthLabel.text = @"JAN";
            break;
        case 2:
            self.monthLabel.text = @"FEB";
            break;
        case 3:
            self.monthLabel.text = @"MAR";
            break;
        case 4:
            self.monthLabel.text = @"APR";
            break;
        case 5:
            self.monthLabel.text = @"MAY";
            break;
        case 6:
            self.monthLabel.text = @"JUN";
            break;
        case 7:
            self.monthLabel.text = @"JUL";
            break;
        case 8:
            self.monthLabel.text = @"AUG";
            break;
        case 9:
            self.monthLabel.text = @"SEPT";
            break;
        case 10:
            self.monthLabel.text = @"OCT";
            break;
        case 11:
            self.monthLabel.text = @"NOV";
            break;
        case 12:
            self.monthLabel.text = @"DEC";
            break;
        default:
            break;
    }
    
    
    // Compute what seasonal fruits are in the current month.
    for (int i = 0; i < [allFruitsBasicInfo count]; i++) {
        bool isInSeason = false;
        FruitItemBasicInfo *item = allFruitsBasicInfo[i];
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
            [seasonalFruit addTarget:self.superViewDelegate action:@selector(addFruitsToDatabase:) forControlEvents:UIControlEventTouchUpInside];
            NSString *imageFileName = [item.fruitName stringByAppendingString:@".png"];
            [seasonalFruit setImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
            seasonalFruit.fruitItem.name = [[NSString alloc] initWithString:item.fruitName];
            
            
            [self.allSeasonalFruitsButton addObject:seasonalFruit];
            [self addSubview:seasonalFruit];
        }
    }
    
    // Fruits display radius is determined by the number of season fruits
    double radius;
    if ([self.allSeasonalFruitsButton count] <= 6) {
        radius = (double) self.frame.size.width / 3;
        for (FruitTouchButton *fruitButton in self.allSeasonalFruitsButton) {
            fruitButton.frame = CGRectMake(0, 0, self.frame.size.width / 7, self.frame.size.width / 7);
        }
    }
    else if ([self.allSeasonalFruitsButton count] <= 12) {
        radius = (double) self.frame.size.width / 2.7;
        for (FruitTouchButton *fruitButton in self.allSeasonalFruitsButton) {
            fruitButton.frame = CGRectMake(0, 0, self.frame.size.width / 8, self.frame.size.width / 8);
        }
    }
    else {
        radius = (double) self.frame.size.width / 2.4;
        for (FruitTouchButton *fruitButton in self.allSeasonalFruitsButton) {
            fruitButton.frame = CGRectMake(0, 0, self.frame.size.width / 9, self.frame.size.width / 9);
        }
    }
    double degreePerButton = (double) 2 * M_PI / [self.allSeasonalFruitsButton count];
    
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        double degree = (double) degreePerButton * i;
        [self.allSeasonalFruitsButton[i] setCenter:CGPointMake(self.frame.size.width / 2 + radius * sin(degree), self.frame.size.height / 2 - radius * cos(degree))];
        
    }
}

- (void) highlightOneFruitTouchButton:(FruitTouchButton *)fruitButton {
    [self.seasonalFruitLabel setAlpha:0.3];
    [self.monthLabel setAlpha:0.3];
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:NO];
        if (self.allSeasonalFruitsButton[i] != fruitButton)
            [self.allSeasonalFruitsButton[i] setAlpha:0.3];
    }
}

- (void) deHighlightFruitTouchButton {
    [self.seasonalFruitLabel setAlpha:1];
    [self.monthLabel setAlpha:1];
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:YES];
        [self.allSeasonalFruitsButton[i] setAlpha:1];
    }
}

- (void) disableAllFruitTouchButtonsInteraction {
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:NO];
    }
}

- (void) enableAllFruitTouchButtonsInteraction {
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:YES];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
