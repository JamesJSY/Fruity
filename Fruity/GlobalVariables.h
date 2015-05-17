//
//  GlobalVariables.h
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FruitItemDBHelper.h"

@interface GlobalVariables : NSObject
{
    int screenWidth;
    int screenHeight;
    
    UIFont *font;
    UIColor *blueColor;
    UIColor *softWhiteColor;
    UIColor *darkGreyColor;
    UIColor *lightGreyColor;
    UIColor *pinkColor;
    
    FruitItemDBHelper *dbHelper;
    
    NSUserDefaults *userPreference;
    
    bool openedFromNotification;
}

@property int screenWidth;
@property int screenHeight;
@property UIFont *font;
@property UIColor *blueColor;
@property UIColor *softWhiteColor;
@property UIColor *darkGreyColor;
@property UIColor *lightGreyColor;
@property UIColor *pinkColor;
@property FruitItemDBHelper *dbHelper;
@property NSUserDefaults *userPreference;
@property bool openedFromNotification;

+ (GlobalVariables *)getInstance;

@end
