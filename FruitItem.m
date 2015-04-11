//
//  FruitItem.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "FruitItem.h"

@implementation FruitItem

-(instancetype)initWithFruitItem:(FruitItem *) item {
    self = [super init];
    if (self) {
        self.ID = item.ID;
        self.name = item.name;
        self.purchaseDate = item.purchaseDate;
        self.startStatus = item.startStatus;
        self.statusChangeThreshold = item.statusChangeThreshold;
        self.isEaten = item.isEaten;
    }
    return self;
}

@end
