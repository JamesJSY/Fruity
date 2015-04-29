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
#import "GlobalVariables.h"


@interface DisplayStorageBottomView ()

@property GlobalVariables *globalVs;

@property (nonatomic) NSMutableArray *allStorageFruitsButton;
@property (nonatomic) NSMutableArray *allQuantityLabels;

@property (nonatomic) UIScrollView *storageListScrollView;

@property (nonatomic) UIImageView *animationMouthOpeningImageViewBottom;
@property (nonatomic) UIImageView *animationChewingImageViewBottom;

@property (nonatomic) float pixelsWidthForDisplayingItem;
@property (nonatomic) float itemDisplayRatio;

@end

@implementation DisplayStorageBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.globalVs = [GlobalVariables getInstance];
        
        // Set the display mode
        self.pixelsWidthForDisplayingItem = self.frame.size.width / 5;
        self.itemDisplayRatio = (float) 2 / 3;
        
        self.backgroundColor = self.globalVs.blueColor;
        self.clipsToBounds = NO;
        
        self.storageListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, self.frame.size.height / 2)];
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
    [self.allQuantityLabels makeObjectsPerformSelector: @selector(removeFromSuperview)];

    NSArray *fruitsInStorage = [[NSArray alloc] initWithArray:[self.superViewDelegate loadAllFruitsInStorageFromDB]];
    
    self.allStorageFruitsButton = [[NSMutableArray alloc] init];
    self.allQuantityLabels = [[NSMutableArray alloc] init];;
    
    // Display all fruits user already bought
    for (int i = 0; i < [fruitsInStorage count]; i++) {
        FruitItem *item = fruitsInStorage[i];
        
        // Check if the item is in the previous list. If it is, then add one to the quantity. If it is not, create a new button
        bool isFound = false;
        for (FruitTouchButton *fruitButton in self.allStorageFruitsButton) {
            if ([item.name isEqualToString:fruitButton.fruitItem.name]) {
                isFound = true;
                fruitButton.numberOfFruits++;
                break;
            }
        }
        
        if (!isFound) {
            FruitTouchButton *fruitInHand = [[FruitTouchButton alloc] init];
            //[fruitInHand addTarget:self action:@selector(showMouth:) forControlEvents:UIControlEventTouchDown];
            [fruitInHand addTarget:self action:@selector(dragFruitButton:withEvent:) forControlEvents:UIControlEventTouchDragInside];
            [fruitInHand addTarget:self action:@selector(releaseFruitButton:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
            NSString *imageFileName = [item.name stringByAppendingString:@".png"];
            [fruitInHand setImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
            fruitInHand.fruitItem = [[FruitItem alloc] initWithFruitItem:item];
            fruitInHand.numberOfFruits = 1;
            fruitInHand.tag = i;
        
            fruitInHand.frame = CGRectMake(20 + [self.allStorageFruitsButton count] * self.pixelsWidthForDisplayingItem, 30, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
        
            [self.allStorageFruitsButton addObject:fruitInHand];
            [self.storageListScrollView addSubview:fruitInHand];
        }
    }
    
    for (FruitTouchButton *fruitButton in self.allStorageFruitsButton) {
        UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        quantityLabel.center = CGPointMake(fruitButton.center.x, fruitButton.center.y + self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
        quantityLabel.font = self.globalVs.font;
        quantityLabel.textAlignment = NSTextAlignmentCenter;
        quantityLabel.textColor = self.globalVs.softWhiteColor;
        
        if ([fruitButton.fruitItem.name isEqualToString:@"raspberry"] ||
            [fruitButton.fruitItem.name isEqualToString:@"strawberry"] ||
            [fruitButton.fruitItem.name isEqualToString:@"blackberry"] ||
            [fruitButton.fruitItem.name isEqualToString:@"blueberry"] ||
            [fruitButton.fruitItem.name isEqualToString:@"cherry"] ||
            [fruitButton.fruitItem.name isEqualToString:@"grape"]) {
            quantityLabel.text = [NSString stringWithFormat:@"%d+", fruitButton.numberOfFruits * 10];
        }
        else {
            quantityLabel.text = [NSString stringWithFormat:@"%d", fruitButton.numberOfFruits];
        }
        
        [self.storageListScrollView addSubview:quantityLabel];
        [self.allQuantityLabels addObject:quantityLabel];
    }
    
    // Resize the scroll board size according to the item size
    self.storageListScrollView.contentSize = CGSizeMake(([self.allStorageFruitsButton count] + 1) *self.pixelsWidthForDisplayingItem, self.frame.size.height / 5);
    
}


- (void)showMouth{
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
        
        // Eat the pressed item in the database
        [self.superViewDelegate eatFruitItemWithID:inputFruit.fruitItem.ID];
                
        // Reload the view that display storage list
        [self loadDisplayStorageBottomView];
    }
    else {
        // If the fruit is not eaten, put the fruit button back to where it was
        unsigned long indexOfFruit = [self.allStorageFruitsButton indexOfObject:inputFruit];
        inputFruit.frame = CGRectMake(20 + indexOfFruit * self.pixelsWidthForDisplayingItem, 30, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
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
