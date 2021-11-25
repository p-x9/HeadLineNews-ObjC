//
//  Item.h
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/09/28.
//  
//

#import <Foundation/Foundation.h>

@interface Item : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *itemDescription;
- (NSDate *)getPubDate;
@end
