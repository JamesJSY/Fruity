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

+ (bool) isGroupFruitItem:(NSString *)fruitName {
    return  [fruitName isEqualToString:@"raspberry"] ||
            [fruitName isEqualToString:@"strawberry"] ||
            [fruitName isEqualToString:@"blackberry"] ||
            [fruitName isEqualToString:@"blueberry"] ||
            [fruitName isEqualToString:@"cherry"] ||
            [fruitName isEqualToString:@"grape"] ||
            [fruitName isEqualToString:@"Boysenberry"];
}

@end
