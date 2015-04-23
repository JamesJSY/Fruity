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
        
        self.quantityButtonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 , self.frame.size.height / 6, self.frame.size.width * 2 / 3, self.frame.size.height / 2)];
        [self addSubview:self.quantityButtonScrollView];
        
        for (int i = 0; i < self.numberOfQuantityButtons; i++) {
            UIButton *quantityButton = [[UIButton alloc] init];
            [quantityButton setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
            quantityButton.backgroundColor = [UIColor clearColor];
            quantityButton.titleLabel.font = self.globalVs.font;
            quantityButton.frame = CGRectMake(i * self.frame.size.width / 5, self.frame.size.height / 6, self.frame.size.width / 6, self.frame.size.height / 3);
            [quantityButton setTitleColor:quantityText.textColor forState:UIControlStateNormal];
            quantityButton.tag = i;
            [quantityButton addTarget:self.superViewDelegate action:@selector(addFruitsToDatabaseWithQuantity:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.quantityButtonScrollView addSubview:quantityButton];
        }
        
        self.quantityButtonScrollView.contentSize = CGSizeMake(self.frame.size.width * self.numberOfQuantityButtons / 5, self.frame.size.height / 3);
    }
    return self;
}

- (void)addButtonDidFinishPressing {
    [self.quantityButtonScrollView setContentOffset:CGPointMake(0, 0)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
