//
//  HeadLineNewsViewDelegate.h
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/11/16.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HeadLineNewsView;

@protocol HeadLineNewsViewDelegate <NSObject>
- (NSArray<Item*> *)nextItemsForView:(HeadLineNewsView *)view;
- (void)headLineNewsView:(HeadLineNewsView *)view animationEndedWith:(NSArray<Item*> *)items;
@end

NS_ASSUME_NONNULL_END

