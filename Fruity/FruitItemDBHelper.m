//
//  FruitItemDBHelper.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/9/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "FruitItemDBHelper.h"
#import "DBManager.h"

@interface FruitItemDBHelper ()

@property DBManager *dbManager;
@property NSMutableArray *fruitItems;
@property NSString *dabaBaseName;

@end

@implementation FruitItemDBHelper

-(instancetype)initDBHelper {
    self = [super init];
    if (self) {
        self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"FruityDB.db"];
        self.dabaBaseName = [[NSString alloc] initWithFormat:@"FRUITITEMINFO"];
    }
    return self;
}

-(void)insertFruitItemIntoDB:(FruitItem *) item {
    // Prepare the query string.
    NSString *query = [NSString stringWithFormat:@"INSERT INTO '%@'(NAME, PURCHASEDATE, STARTSTATUS, STATUSCHANGETHRESHOLD, ISEATEN, EATDATE) values('%@', '%@', %f, %f, %d, '%@')", self.dabaBaseName ,item.name, item.purchaseDate, item.startStatus, item.statusChangeThreshold, item.isEaten, item.eatDate] ;
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

-(NSArray *)loadAllFruitItemsEatenFromDBInYear:(int)inputYear month:(int)inputMonth day:(int)inputDay {
    NSString *monthString;
    NSString *dayString;
    if (inputMonth < 10) {
        monthString = [NSString stringWithFormat:@"0%d", inputMonth];
    }
    else {
        monthString = [NSString stringWithFormat:@"%d", inputMonth];
    }
    if (inputDay < 10) {
        dayString = [NSString stringWithFormat:@"0%d", inputDay];
    }
    else {
        dayString = [NSString stringWithFormat:@"%d", inputDay];
    }
    NSString *dateString = [NSString stringWithFormat:@"%d-%@-%@", inputYear, monthString, dayString];
    
    NSString *query = [NSString stringWithFormat:(@"SELECT * FROM '%@' WHERE ISEATEN = 1 AND EATDATE = '%@'"), self.dabaBaseName, dateString];
    
    // Raw data obatained from database via the query
    NSArray *data = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reinitialize return data in the form of ToDoItem.
    if (self.fruitItems != nil) {
        self.fruitItems = nil;
    }
    self.fruitItems = [[NSMutableArray alloc] init];
    
    // Get the index of column name.
    NSInteger indexOfID = [self.dbManager.arrColumnNames indexOfObject:@"ID"];
    NSInteger indexOfName = [self.dbManager.arrColumnNames indexOfObject:@"NAME"];
    NSInteger indexOfPurchaseDate = [self.dbManager.arrColumnNames indexOfObject:@"PURCHASEDATE"];
    NSInteger indexOfStartStatus = [self.dbManager.arrColumnNames indexOfObject:@"STARTSTATUS"];
    NSInteger indexOfStatusChangeThreshold = [self.dbManager.arrColumnNames indexOfObject:@"STATUSCHANGETHRESHOLD"];
    NSInteger indexOfIsEaten = [self.dbManager.arrColumnNames indexOfObject:@"ISEATEN"];
    NSInteger indexOfEatDate = [self.dbManager.arrColumnNames indexOfObject:@"EATDATE"];
    
    // Transform raw data to ToDoItem form.
    for (int i = 0; i < [data count]; i++) {
        FruitItem *item = [[FruitItem alloc] init];
        item.ID = (int)[data[i][indexOfID] integerValue];
        item.name = data[i][indexOfName];
        item.purchaseDate = data[i][indexOfPurchaseDate];
        item.startStatus = [data[i][indexOfStartStatus] floatValue];
        item.statusChangeThreshold = [data[i][indexOfStatusChangeThreshold] floatValue];
        item.isEaten = [data[i][indexOfIsEaten] boolValue];
        item.eatDate = data[i][indexOfEatDate];
        [self.fruitItems addObject:item];
    }
    
    return (NSArray *)self.fruitItems;
}

-(NSArray *)loadAllFruitItemsNotEatenFromDB {
    NSString *query = [NSString stringWithFormat:(@"SELECT * FROM '%@' WHERE ISEATEN = 0"), self.dabaBaseName];
    
    // Raw data obatained from database via the query
    NSArray *data = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reinitialize return data in the form of ToDoItem.
    if (self.fruitItems != nil) {
        self.fruitItems = nil;
    }
    self.fruitItems = [[NSMutableArray alloc] init];
    
    // Get the index of column name.
    NSInteger indexOfID = [self.dbManager.arrColumnNames indexOfObject:@"ID"];
    NSInteger indexOfName = [self.dbManager.arrColumnNames indexOfObject:@"NAME"];
    NSInteger indexOfPurchaseDate = [self.dbManager.arrColumnNames indexOfObject:@"PURCHASEDATE"];
    NSInteger indexOfStartStatus = [self.dbManager.arrColumnNames indexOfObject:@"STARTSTATUS"];
    NSInteger indexOfStatusChangeThreshold = [self.dbManager.arrColumnNames indexOfObject:@"STATUSCHANGETHRESHOLD"];
    NSInteger indexOfIsEaten = [self.dbManager.arrColumnNames indexOfObject:@"ISEATEN"];
    NSInteger indexOfEatDate = [self.dbManager.arrColumnNames indexOfObject:@"EATDATE"];
    
    // Transform raw data to ToDoItem form.
    for (int i = 0; i < [data count]; i++) {
        FruitItem *item = [[FruitItem alloc] init];
        item.ID = (int)[data[i][indexOfID] integerValue];
        item.name = data[i][indexOfName];
        item.purchaseDate = data[i][indexOfPurchaseDate];
        item.startStatus = [data[i][indexOfStartStatus] floatValue];
        item.statusChangeThreshold = [data[i][indexOfStatusChangeThreshold] floatValue];
        item.isEaten = [data[i][indexOfIsEaten] boolValue];
        item.eatDate = data[i][indexOfEatDate];
        [self.fruitItems addObject:item];
    }
    
    return (NSArray *)self.fruitItems;
}

-(void)deleteFruitItemsFromDB:(int) ID {
    // Prepare the query.
    NSString *query = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE ID = %d", self.dabaBaseName, ID];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

- (void)eatFruitItemFromDB:(int) ID date:(NSString*) eatDate{
    // Prepare the query string.
    NSString *query = [NSString stringWithFormat:@"UPDATE '%@' SET ISEATEN = %d, EATDATE = '%@' WHERE ID = %d", self.dabaBaseName, 1, eatDate, ID] ;
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

-(void)updateFruitItemsFromDB:(FruitItem *) item {
    // Prepare the query string.
    NSString *query = [NSString stringWithFormat:@"UPDATE '%@' SET NAME = '%@', PURCHASEDATE = '%@', STARTSTATUS = %f, STATUSCHANGETHRESHOLD = %f, ISEATEN = %d, WHERE ID = %d", self.dabaBaseName, item.name, item.purchaseDate, item.startStatus, item.statusChangeThreshold, item.isEaten, item.ID] ;
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

@end
