//
//  RSSParser.h
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/09/28.
//  
//

#import <Foundation/Foundation.h>

@interface RSSParser : NSObject 
- (instancetype)init;
- (void)parseWithURL:(NSURL*)url completionHandler:(void (^)(NSArray* items, NSError* error))completionHandler;
@end
