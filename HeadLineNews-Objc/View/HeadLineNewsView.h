//
//  HeadLineNewsView.h
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/11/16.
//  
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "HeadLineNewsViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface HeadLineNewsView : UIView
@property (strong, nonatomic) UILabel *newsLabel;
@property (weak, nonatomic, nullable) id <HeadLineNewsViewDelegate> delegate;
@property (assign, nonatomic) BOOL isRunning;
@property (assign, nonatomic) BOOL usePip;
@property (assign, nonatomic) CGFloat speed;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *font;
@property (assign, nonatomic) CGFloat newsSpacing;
@property (getter=currentItem, nonatomic) Item *currentItem;
-(void)startAnimatingWith:(NSArray<Item*> *)items;
-(void)stopAnimation;
@end

NS_ASSUME_NONNULL_END
