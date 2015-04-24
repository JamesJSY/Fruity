//
//  DisplayStorageBottomView.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "DisplayStorageBottomView.h"
#import "FruitItem.h"
#import "FruitTouchButton.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DisplayStorageBottomView ()

@property (nonatomic) NSMutableArray *allStorageFruitsButton;

@property (nonatomic) UIScrollView *storageListScrollView;

@property (nonatomic) UIImageView *animationMouthOpeningImageViewBottom;
@property (nonatomic) UIImageView *animationChewingImageViewBottom;

@end

@implementation DisplayStorageBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColorFromRGB(0xadd9c2);
        self.clipsToBounds = NO;
        
        self.storageListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, self.frame.size.height / 3)];
        self.storageListScrollView.backgroundColor = [UIColor clearColor];
        self.storageListScrollView.clipsToBounds = NO;
        [self addSubview:self.storageListScrollView];
        
        // Initialize the animation image view
        self.animationChewingImageViewBottom = [[UIImageView alloc] init];
        NSMutableArray *chewingImages = [[NSMutableArray alloc] init];
        for (int i = 4; i < 8; i++) {
            [chewingImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"monsterChew%d.png", i]]];
        }
        [self.animationChewingImageViewBottom setAnimationImages:chewingImages];
        self.animationChewingImageViewBottom.image = [UIImage imageNamed:@"monsterChew3.png"];
        [self.animationChewingImageViewBottom setAnimationDuration:1.0];
        [self.animationChewingImageViewBottom setAnimationRepeatCount:1];
        self.animationChewingImageViewBottom.frame = CGRectMake(0, 0, self.frame.size.width / 3, self.frame.size.width / 3);
        self.animationChewingImageViewBottom.center = CGPointMake(self.frame.size.width / 2, 0);
        [self.animationChewingImageViewBottom setHidden:YES];
        [self insertSubview:self.animationChewingImageViewBottom belowSubview:self.storageListScrollView];
        
        // Initialize the animation image view
        self.animationMouthOpeningImageViewBottom = [[UIImageView alloc] init];
        NSMutableArray *mouthOpeningImages = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i++) {
            [mouthOpeningImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"monsterChew%d.png", i]]];
        }
        self.animationMouthOpeningImageViewBottom.image = [UIImage imageNamed:@"monsterChew0.png"];
        [self.animationMouthOpeningImageViewBottom setAnimationImages:mouthOpeningImages];
        [self.animationMouthOpeningImageViewBottom setAnimationDuration:0.3];
        [self.animationMouthOpeningImageViewBottom setAnimationRepeatCount:1];
        self.animationMouthOpeningImageViewBottom.frame = CGRectMake(0, 0, self.frame.size.width / 3, self.frame.size.width / 3);
        self.animationMouthOpeningImageViewBottom.center = CGPointMake(self.frame.size.width / 2, 0);
        [self insertSubview:self.animationMouthOpeningImageViewBottom belowSubview:self.animationChewingImageViewBottom];
        
        
    }
    return self;
}

- (void)loadDisplayStorageBottomView {
    
    // Remove all subviews currently in the fruitsInHandView
    [self.allStorageFruitsButton makeObjectsPerformSelector: @selector(removeFromSuperview)];

    NSArray *fruitsInStorage = [[NSArray alloc] initWithArray:[self.superViewDelegate loadAllFruitsInStorageFromDB]];
    
    self.allStorageFruitsButton = [[NSMutableArray alloc] init];
    
    // Set the display mode
    float pixelsWidthForDisplayingItem = self.frame.size.width / 5;
    float itemDisplayRatio = (float) 2 / 3;
    
    // Display all fruits user already bought
    for (int i = 0; i < [fruitsInStorage count]; i++) {
        FruitItem *item = fruitsInStorage[i];
        
        FruitTouchButton *fruitInHand = [[FruitTouchButton alloc] init];
        [fruitInHand addTarget:self action:@selector(showMouth:) forControlEvents:UIControlEventTouchDown];
        [fruitInHand addTarget:self action:@selector(dragFruitButton:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [fruitInHand addTarget:self action:@selector(releaseFruitButton:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *imageFileName = [item.name stringByAppendingString:@".png"];
        [fruitInHand setImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
        fruitInHand.fruitItem = [[FruitItem alloc] initWithFruitItem:item];
        fruitInHand.tag = i;
        
        fruitInHand.frame = CGRectMake(20 + i * pixelsWidthForDisplayingItem, 30, pixelsWidthForDisplayingItem * itemDisplayRatio, pixelsWidthForDisplayingItem * itemDisplayRatio);
        
        [self.allStorageFruitsButton addObject:fruitInHand];
        [self.storageListScrollView addSubview:fruitInHand];
    }
    // Resize the scroll board size according to the item size
    self.storageListScrollView.contentSize = CGSizeMake(([fruitsInStorage count] + 1) *pixelsWidthForDisplayingItem, self.frame.size.height / 5);
    
}

- (void)showMouth:(FruitTouchButton *)inputFruit {
    //[self.animationMouthOpeningImageViewBottom setImage:[UIImage imageNamed:@"monsterChew3.png"]];
    [self.animationMouthOpeningImageViewBottom startAnimating];
    [self performSelector:@selector(animationAfterMouthDidShow) withObject:nil
               afterDelay:self.animationMouthOpeningImageViewBottom.animationDuration - 0.1];
}

- (void)dragFruitButton:(FruitTouchButton*)inputFruit withEvent:(UIEvent*) event{
    inputFruit.center = [[[event allTouches] anyObject] locationInView:self.storageListScrollView];
}

- (void)releaseFruitButton:(FruitTouchButton*)inputFruit withEvent:(UIEvent*) event{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self];
    
    if ( CGRectContainsPoint(self.animationMouthOpeningImageViewBottom.frame, point)) {
        // Start chewing animation
        //[self.animationMouthOpeningImageViewBottom setHidden:YES];
        //[self.animationChewingImageViewBottom setHidden:NO];
        //[self performSelector:@selector(animationAfterDiDChew) withObject:nil afterDelay:self.animationChewingImageViewBottom.animationDuration];
        [self.animationChewingImageViewBottom startAnimating];
        
        
        
        // Delete the pressed item in the database
        [self.superViewDelegate eatFruitItemWithID:inputFruit.fruitItem.ID];
                
        // Reload the view that display storage list
        [self loadDisplayStorageBottomView];
    }
    else {
        inputFruit.frame = CGRectMake((float)20 + inputFruit.tag * self.frame.size.width / 5, 30, (float) self.frame.size.width / 5 * 2 / 3, (float) self.frame.size.width / 5 * 2 / 3);
        //[self.animationMouthOpeningImageViewBottom setImage:[UIImage imageNamed:@"monsterChew0.png"]];
    }
}

- (void)animationAfterMouthDidShow {
    self.animationChewingImageViewBottom.hidden = NO;
    //[self.animationMouthOpeningImageViewBottom setImage:[UIImage imageNamed:@"monsterChew0.png"]];
    //[self.animationMouthOpeningImageViewBottom stopAnimating];
}

- (void)animationAfterDiDChew {
    [self.animationChewingImageViewBottom setHidden:YES];
}

- (void)mainViewDidMoveDown {
    self.animationChewingImageViewBottom.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
