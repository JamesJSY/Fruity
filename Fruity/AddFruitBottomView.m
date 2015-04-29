//
//  AddFruitBottomView.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "AddFruitBottomView.h"
#import "GlobalVariables.h"

@interface AddFruitBottomView ()

@property GlobalVariables *globalVs;
@property UIScrollView *quantityButtonScrollView;
@property int numberOfQuantityButtons;

@property NSMutableArray *allQuantityButtons;

@end

@implementation AddFruitBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.globalVs = [GlobalVariables getInstance];
        self.numberOfQuantityButtons = 9;
        
        self.backgroundColor = [UIColor blackColor];
        
        UITextView *quantityText = [[UITextView alloc] init];
        quantityText.frame = CGRectMake(0, self.frame.size.height / 3, self.frame.size.width / 3, self.frame.size.height / 2);
        quantityText.text = @"Quantity";
        quantityText.textAlignment = NSTextAlignmentCenter;
        quantityText.textColor = self.globalVs.lightGreyColor;
        quantityText.font = self.globalVs.font;
        [quantityText setEditable:NO];
        quantityText.backgroundColor = [UIColor clearColor];
        
        [self addSubview:quantityText];
        
        self.quantityButtonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 , 0, self.frame.size.width * 2 / 3, self.frame.size.height)];
        [self addSubview:self.quantityButtonScrollView];
        
    }
    return self;
}

- (void)addButtonDidFinishPressing {
    [self.quantityButtonScrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)setUpQuantitiesWithQuantityBase:(int)base {
    // Remove all quantity buttons
    [self.allQuantityButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.allQuantityButtons = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.numberOfQuantityButtons; i++) {
        UIButton *quantityButton = [[UIButton alloc] init];
        NSString *titleString;
        if (base == 1) {
            titleString = [NSString stringWithFormat:@"%d", i + 1];
        }
        else {
            titleString = [NSString stringWithFormat:@"%d+", (i + 1) * base];
        }
        [quantityButton setTitle:titleString forState:UIControlStateNormal];
        quantityButton.backgroundColor = [UIColor clearColor];
        quantityButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:22];
        quantityButton.frame = CGRectMake(i * self.frame.size.width / 5, self.frame.size.height / 3, self.frame.size.width / 6, self.frame.size.height / 3);
        [quantityButton setTitleColor:self.globalVs.lightGreyColor forState:UIControlStateNormal];
        quantityButton.tag = i;
        [quantityButton addTarget:self.superViewDelegate action:@selector(addFruitsToDatabaseWithQuantity:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.allQuantityButtons addObject:quantityButton];
        [self.quantityButtonScrollView addSubview:quantityButton];
    }
    
    self.quantityButtonScrollView.contentSize = CGSizeMake(self.frame.size.width * self.numberOfQuantityButtons / 5, self.frame.size.height / 3);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
