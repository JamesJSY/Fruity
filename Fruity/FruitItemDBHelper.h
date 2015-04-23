//
//  FruitItemDBHelper.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FruitItem.h"

@interface FruitItemDBHelper : NSObject

-(instancetype)initDBHelper;

-(void)insertFruitItemIntoDB:(FruitItem *) item;

-(NSArray *)loadAllFruitItemsNotEatenFromDB;

-(void)deleteFruitItemsFromDB:(int) ID;

-(void)updateFruitItemsFromDB:(FruitItem *) item;

-(void)eatFruitItemFromDB:(int) ID;

@end
