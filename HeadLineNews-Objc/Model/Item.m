//
//  Item.m
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/09/28.
//  
//

#import "Item.h"
#import <Foundation/Foundation.h>

@interface Item()

@end

@implementation Item
- (NSDate *)getPubDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US_POSIX"];
    formatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss ZZZZ";
    
    return [formatter dateFromString: self.pubDate];
}


@end
