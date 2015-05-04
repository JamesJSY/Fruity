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
@property (nonatomic) UIImageView *dustbinImageView;
@property (nonatomic) UIImageView *tipsImageView;

@property (nonatomic) float pixelsWidthForDisplayingItem;
@property (nonatomic) float itemDisplayRatio;

@property (nonatomic) NSTimer *longPressRecognizerTimer;

@property (nonatomic) bool isShowingDustbin;
//@property (nonatomic) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation DisplayStorageBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.globalVs = [GlobalVariables getInstance];
        self.isShowingDustbin = NO;
        
        // Set the display mode
        self.pixelsWidthForDisplayingItem = self.frame.size.width / 4;
        self.itemDisplayRatio = (float) 2 / 3;
        
        self.backgroundColor = self.globalVs.blueColor;
        self.clipsToBounds = NO;
        
        self.storageListScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, self.frame.size.height / 2)];
        self.storageListScrollView.backgroundColor = [UIColor clearColor];
        self.storageListScrollView.clipsToBounds = NO;
        self.storageListScrollView.showsHorizontalScrollIndicator = NO;
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
        
        // Initialize the dustbin image view
        self.dustbinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0)];
        self.dustbinImageView.backgroundColor = [UIColor blackColor];
        //self.dustbinImageView.hidden = YES;
        [self addSubview:self.dustbinImageView];
        
        // Initialize the tips image view
        self.tipsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 10, self.frame.size.width / 10)];
        self.tipsImageView.center = CGPointMake(self.frame.size.width / 2, - self.animationChewingImageViewBottom.frame.size.height * 4 / 5);
        self.tipsImageView.image = [UIImage imageNamed:@"balloon.png"];
        [self addSubview:self.tipsImageView];
        
        /*
        // Set up a long press gesture recognizer for every fruit in storage to enter edit mode
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(enterEditMode)];
        self.longPressGesture.minimumPressDuration = 1.0f;
        self.longPressGesture.allowableMovement = 100.0f;*/
        
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
            //[fruitInHand addTarget:self action:@selector(enterEditMode:) forControlEvents:UIControlEventTouchDown];
            [fruitInHand addTarget:self action:@selector(dragFruitButton:withEvent:) forControlEvents:UIControlEventTouchDragInside];
            [fruitInHand addTarget:self action:@selector(releaseFruitButton:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
            NSString *imageFileName = [item.name stringByAppendingString:@".png"];
            [fruitInHand setImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
            fruitInHand.fruitItem = [[FruitItem alloc] initWithFruitItem:item];
            fruitInHand.numberOfFruits = 1;
            fruitInHand.tag = [self.allStorageFruitsButton count];
        
            fruitInHand.frame = CGRectMake(20 + [self.allStorageFruitsButton count] * self.pixelsWidthForDisplayingItem, 30, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
        
            [self.allStorageFruitsButton addObject:fruitInHand];
            [self.storageListScrollView addSubview:fruitInHand];
        }
    }
    
    for (FruitTouchButton *fruitButton in self.allStorageFruitsButton) {
        UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.pixelsWidthForDisplayingItem, 30)];
        quantityLabel.center = CGPointMake(fruitButton.center.x, fruitButton.center.y + self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
        quantityLabel.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:22];
        quantityLabel.textAlignment = NSTextAlignmentCenter;
        quantityLabel.textColor = self.globalVs.softWhiteColor;
        quantityLabel.tag = fruitButton.tag;
        
        if ([FruitItem isGroupFruitItem:fruitButton.fruitItem.name]) {
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
    [self.animationMouthOpeningImageViewBottom startAnimating];
    [self performSelector:@selector(animationAfterMouthDidShow) withObject:nil
               afterDelay:self.animationMouthOpeningImageViewBottom.animationDuration - 0.1];
}

- (void)dragFruitButton:(FruitTouchButton*)inputFruit withEvent:(UIEvent*) event{
    inputFruit.center = [[[event allTouches] anyObject] locationInView:self.storageListScrollView];
    
    // Get the drag point and check if it is below a certain line. If it is, show the dustbin for deleting fruits
    CGPoint point = [[[event allTouches] anyObject] locationInView:self];
    if ( point.y > self.frame.size.height * 3 / 5 && self.isShowingDustbin == NO) {
        [self showDustbin];
        self.isShowingDustbin = YES;
    }
    else if (point.y <= self.frame.size.height * 3 / 5 && self.isShowingDustbin == YES) {
        [self hideDustbin];
        self.isShowingDustbin = NO;
    }
}

- (void)releaseFruitButton:(FruitTouchButton*)inputFruit withEvent:(UIEvent*) event{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self];
    
    // If the user drags the fruit into the little blue's mouth and release it
    if ( CGRectContainsPoint(self.animationMouthOpeningImageViewBottom.frame, point)) {
        
        //[self.animationMouthOpeningImageViewBottom setHidden:YES];
        //[self.animationChewingImageViewBottom setHidden:NO];
        //[self performSelector:@selector(animationAfterDiDChew) withObject:nil afterDelay:self.animationChewingImageViewBottom.animationDuration];
        
        // Record the tag number of the quantity label so that we can change its color to pink and back then
        UILabel *eatenFruitQuantityLabel = self.allQuantityLabels[inputFruit.tag];
        
        // Change the quantity to one less and put the fruit button back to where it was
        if ([FruitItem isGroupFruitItem:inputFruit.fruitItem.name]) {
            eatenFruitQuantityLabel.text = [NSString stringWithFormat:@"%d+", (int)([eatenFruitQuantityLabel.text integerValue] / 10 - 1 )* 10];
        }
        else {
            eatenFruitQuantityLabel.text = [NSString stringWithFormat:@"%d", (int)[eatenFruitQuantityLabel.text integerValue] - 1];
        }
        inputFruit.frame = CGRectMake(20 + inputFruit.tag * self.pixelsWidthForDisplayingItem, 30, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
        
        // Start chewing animation
        [self.animationChewingImageViewBottom startAnimating];
        
        // Eat the pressed item in the database
        [self.superViewDelegate eatFruitItemWithID:inputFruit.fruitItem.ID];
        
        // Change the quantity label to pink and back then to let the user know which fruit is eaten
        [UIView transitionWithView:eatenFruitQuantityLabel
                          duration:0.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            eatenFruitQuantityLabel.textColor = self.globalVs.pinkColor;
                        }
                        completion:^(BOOL finished) {
                            [UIView transitionWithView:eatenFruitQuantityLabel
                                              duration:1.0
                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                            animations:^{
                                                eatenFruitQuantityLabel.textColor = self.globalVs.softWhiteColor;
                                            }
                                            completion:^(BOOL finished) {
                                                // Reload the view that display storage list
                                                [self loadDisplayStorageBottomView];
                                            }];
                        }];
        

    }
    // If the user drags the fruit in the dustbin area
    else if (point.y > self.frame.size.height * 2 / 3) {
        // Delete the selected fruit that is not eaten in the
        [self.superViewDelegate deleteNotEatenFruitItemWithName:inputFruit.fruitItem.name];
        
        // Reload the view that display storage list
        [self loadDisplayStorageBottomView];
    }
    else {
        // If the fruit is not eaten nor deleted, put the fruit button back to where it was
        unsigned long indexOfFruit = [self.allStorageFruitsButton indexOfObject:inputFruit];
        inputFruit.frame = CGRectMake(20 + indexOfFruit * self.pixelsWidthForDisplayingItem, 30, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio, self.pixelsWidthForDisplayingItem * self.itemDisplayRatio);
    }
}

- (void)enterEditMode:(FruitTouchButton *) fruitButton {
    /*NSLog(@"Entering the edit mode.");
    
    for (int i = 0; i < [self.allStorageFruitsButton count]; i++) {
        FruitTouchButton *fruitButton = self.allStorageFruitsButton[i];
        UILabel *quantityLabel = self.allQuantityLabels[i];
        
        quantityLabel.hidden = YES;
        fruitButton.frame = CGRectOffset(fruitButton.frame, 0, fruitButton.frame.size.height / 2);
    }
    
    [self.animationChewingImageViewBottom stopAnimating];
    self.animationChewingImageViewBottom.image = [UIImage imageNamed:@"monsterChew0.png"];*/
    [self.superViewDelegate deleteNotEatenFruitItemWithName:fruitButton.fruitItem.name];
    [self loadDisplayStorageBottomView];
}

- (void)quitEditMode {
    NSLog(@"Quitting the edit mode.");
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

- (void)showDustbin {
    //self.dustbinImageView.hidden = NO;
    //self.dustbinImageView.frame = CGRectMake(0, self.frame.size.height * 5 / 6, self.frame.size.width, self.frame.size.height / 6);
    /*CAShapeLayer *shape = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.center radius:(self.bounds.size.width / 2) startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
    shape.path = path.CGPath;
    self.dustbinImageView.layer.mask = shape;*/
    
    self.animationChewingImageViewBottom.image = [UIImage imageNamed:@"unhappy-face.png"];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         self.dustbinImageView.frame = CGRectMake(0, self.frame.size.height * 5 / 6, self.frame.size.width, self.frame.size.height / 6);
                         
                         self.tipsImageView.frame = CGRectMake(0, 0, self.frame.size.width * 2 / 3, self.frame.size.width * 2 / 3);
                         self.tipsImageView.center = CGPointMake(self.frame.size.width / 2, - self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                    }];
    //UIBezierPath *bpath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, self.frame.size.height * 5 / 6, self.frame.size.width, self.frame.size.height / 6)];
    //self.dustbinImageView.frame = ;
    //self.dustbinImageView.frame = CGRectMake(0, self.frame.size.height * 5 / 6, self.frame.size.width, self.frame.size.height / 6);
    //self.dustbinImageView.layer.cornerRadius = self.frame.size.width / 3;
}

- (void)hideDustbin {
    
    self.animationChewingImageViewBottom.image = [UIImage imageNamed:@"monsterChew3.png"];
    self.animationChewingImageViewBottom.hidden = YES;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         self.dustbinImageView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
                         self.tipsImageView.frame = CGRectMake(0, 0, self.frame.size.width / 10, self.frame.size.width / 10);
                         self.tipsImageView.center = CGPointMake(self.frame.size.width / 2, - self.animationChewingImageViewBottom.frame.size.height * 4 / 5);
                         

                     }
                     completion:^(BOOL finished) {
                         [self showMouth];
                     }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
