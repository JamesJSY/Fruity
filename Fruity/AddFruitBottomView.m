//
//  AddFruitBottomView.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "AddFruitBottomView.h"
#import "GlobalVariables.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AddFruitBottomView ()

@property GlobalVariables *globalVs;

@end

@implementation AddFruitBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.globalVs = [GlobalVariables getInstance];
        
        self.backgroundColor = [UIColor blackColor];
        
        UITextView *quantityText = [[UITextView alloc] init];
        quantityText.frame = CGRectMake(0, self.frame.size.height / 3, self.frame.size.width / 3, self.frame.size.height / 2);
        quantityText.text = @"Quantity";
        quantityText.textAlignment = NSTextAlignmentCenter;
        quantityText.textColor = UIColorFromRGB(0xabacab);
        quantityText.font = self.globalVs.font;
        [quantityText setEditable:NO];
        quantityText.backgroundColor = [UIColor clearColor];
        
        [self addSubview:quantityText];
        
        for (int i = 0; i < 3; i++) {
            UIButton *quantityButton = [[UIButton alloc] init];
            [quantityButton setTitle:[NSString stringWithFormat:@"%d", i + 1] forState:UIControlStateNormal];
            quantityButton.backgroundColor = [UIColor clearColor];
            quantityButton.titleLabel.font = self.globalVs.font;
            quantityButton.tintColor = quantityText.textColor;
            quantityButton.frame = CGRectMake(self.frame.size.width / 3 + i * self.frame.size.width / 5, self.frame.size.height / 3, self.frame.size.width / 6, self.frame.size.height / 2);
            [quantityButton setTitleColor:UIColorFromRGB(0xabacab) forState:UIControlStateNormal];
            quantityButton.tag = i;
            [quantityButton addTarget:self.superViewDelegate action:@selector(addFruitsToDatabaseWithQuantity:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:quantityButton];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
