//
//  FruitItem.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FruitItem : NSObject

@property int ID;
@property NSString* name;
@property NSString* purchaseDate;
@property NSString* eatDate;
@property float startStatus;
@property float statusChangeThreshold;
@property bool isEaten;

-(instancetype)initWithFruitItem:(FruitItem *) item;

+ (bool) isGroupFruitItem:(NSString *) fruitName;

@end
