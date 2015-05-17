//
//  GlobalVariables.m
//  Fruity
//
//  Created by Shiyuan Jiang on 4/18/15.
//  Copyright (c) 2015 Shiyuan Jiang. All rights reserved.
//

#import "GlobalVariables.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation GlobalVariables

@synthesize screenWidth;
@synthesize screenHeight;
@synthesize font;
@synthesize blueColor;
@synthesize softWhiteColor;
@synthesize darkGreyColor;
@synthesize lightGreyColor;
@synthesize pinkColor;
@synthesize dbHelper;
@synthesize userPreference;
@synthesize openedFromNotification;

static GlobalVariables *instance = nil;

+ (GlobalVariables *)getInstance {
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [[GlobalVariables alloc] init];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            instance.screenWidth = screenRect.size.width;
            instance.screenHeight = screenRect.size.height;
            instance.font = [UIFont fontWithName:@"AvenirLTStd-Light" size:16];
            
            instance.blueColor = UIColorFromRGB(0xadd9c2);
            instance.softWhiteColor = UIColorFromRGB(0xf4f4cd);
            instance.darkGreyColor = UIColorFromRGB(0x676f6b);
            instance.lightGreyColor = UIColorFromRGB(0xabacab);
            instance.pinkColor = UIColorFromRGB(0xd26168);
            
            instance.dbHelper = [[FruitItemDBHelper alloc] initDBHelper];
            
            // Initialize the user preference
            instance.userPreference = [[NSUserDefaults alloc] init];
            
            instance.openedFromNotification = NO;
            
            /*
            // Record the start date of using Fruity so that no date earlier than this will be displayed in the calendar view
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
            comps.month = 1;
            comps.day = 1;
            NSDate *firstDayOfMonth = [calendar dateFromComponents:comps];*/
            
            if ([instance.userPreference valueForKey:@"FruityStartDate"] == nil) {
                [instance.userPreference setValue:[NSDate date] forKey:@"FruityStartDate"];
            }
        }
    }
    return instance;
}

@end
