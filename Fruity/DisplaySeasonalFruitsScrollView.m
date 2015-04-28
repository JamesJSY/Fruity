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


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DisplaySeasonalFruitsScrollView ()

//@property GlobalVariables *globalVs;

@property NSMutableArray *seasonalFruits;

@property UITextView *seasonalFruitTextView;
@property UITextView *monthTextView;

@property NSMutableArray *allSeasonalFruitsButton;

@end

@implementation DisplaySeasonalFruitsScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //self.globalVs = [GlobalVariables getInstance];
        self.seasonalFruitTextView = [[UITextView alloc] init];
        self.monthTextView = [[UITextView alloc] init];
        
        // Set up the two textViews in the middle
        self.seasonalFruitTextView.text = @"Seasonal Fruits in";
        self.seasonalFruitTextView.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:14];
        self.seasonalFruitTextView.backgroundColor = [UIColor clearColor];
        self.seasonalFruitTextView.textColor = UIColorFromRGB(0xabacab);
        self.seasonalFruitTextView.frame = CGRectMake(0, 0, 110, 50);
        self.seasonalFruitTextView.textAlignment = NSTextAlignmentCenter;
        self.seasonalFruitTextView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 20);
        self.seasonalFruitTextView.editable = NO;
        [self addSubview:self.seasonalFruitTextView];
        
        self.monthTextView.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:40];
        self.monthTextView.backgroundColor = [UIColor clearColor];
        self.monthTextView.textColor = UIColorFromRGB(0x676f6b);
        self.monthTextView.textAlignment = NSTextAlignmentCenter;
        self.monthTextView.frame = CGRectMake(0, 0, 100, 50);
        self.monthTextView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 20);
        self.monthTextView.editable = NO;
        [self addSubview:self.monthTextView];
    }
    return (self);
}

- (void)loadViewWithSeasonalFruitsBasicInfo:(NSMutableArray *)allFruitsBasicInfo withMonth:(int) month{
    // Remove all subviews currently in the fruitsAddView
    [self.allSeasonalFruitsButton makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    // Reinitialize seasonal fruits and related buttons
    self.seasonalFruits = [[NSMutableArray alloc] init];
    self.allSeasonalFruitsButton = [[NSMutableArray alloc] init];

    switch (month) {
        case 1:
            self.monthTextView.text = @"January";
            break;
        case 2:
            self.monthTextView.text = @"February";
            break;
        case 3:
            self.monthTextView.text = @"March";
            break;
        case 4:
            self.monthTextView.text = @"April";
            break;
        case 5:
            self.monthTextView.text = @"May";
            break;
        case 6:
            self.monthTextView.text = @"June";
            break;
        case 7:
            self.monthTextView.text = @"July";
            break;
        case 8:
            self.monthTextView.text = @"August";
            break;
        case 9:
            self.monthTextView.text = @"September";
            break;
        case 10:
            self.monthTextView.text = @"October";
            break;
        case 11:
            self.monthTextView.text = @"November";
            break;
        case 12:
            self.monthTextView.text = @"December";
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
            seasonalFruit.frame = CGRectMake(0, 0, self.frame.size.width / 7, self.frame.size.width / 7);
            
            [self.allSeasonalFruitsButton addObject:seasonalFruit];
            [self addSubview:seasonalFruit];
        }
    }
    
    double radius = (double) self.frame.size.width / 3;
    double degreePerButton = (double) 2 * M_PI / [self.allSeasonalFruitsButton count];
    
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        double degree = (double) degreePerButton * i;
        [self.allSeasonalFruitsButton[i] setCenter:CGPointMake(self.frame.size.width / 2 + radius * sin(degree), self.frame.size.height / 2 - radius * cos(degree))];
        
    }
}

- (void) highlightOneFruitTouchButton:(FruitTouchButton *)fruitButton {
    [self.seasonalFruitTextView setAlpha:0.3];
    [self.monthTextView setAlpha:0.3];
    for (int i = 0; i < [self.allSeasonalFruitsButton count]; i++) {
        [self.allSeasonalFruitsButton[i] setUserInteractionEnabled:NO];
        if (self.allSeasonalFruitsButton[i] != fruitButton)
            [self.allSeasonalFruitsButton[i] setAlpha:0.3];
    }
}

- (void) deHighlightFruitTouchButton {
    [self.seasonalFruitTextView setAlpha:1];
    [self.monthTextView setAlpha:1];
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
