//
//  HeadLineNewsView.m
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/11/16.
//  
//

#import "HeadLineNewsView.h"

@interface HeadLineNewsView() <CAAnimationDelegate>
@property (strong, nonatomic) NSArray<Item*> *items;
@property (assign, nonatomic) NSInteger currentIndex;
-(Item*)currentItem;
@end

@implementation HeadLineNewsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.newsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.currentIndex = -1;
    self.speed = 1.0;
    self.textColor = UIColor.whiteColor;
    self.font = [UIFont systemFontOfSize:20];
    self.newsSpacing = 0;
    self.isRunning = false;
    self.items = @[];
    
    [self setupView];
    
    return  self;
}

-(Item*)currentItem {
    if(self.currentIndex < 0 || self.items.count < self.currentIndex){
        return  nil;
    }
    return self.items[self.currentIndex];
}

-(void)setupView {
    self.backgroundColor = UIColor.blackColor;
    self.newsLabel.textColor = self.textColor;
    self.newsLabel.font = self.font;
    
    [self addSubview:self.newsLabel];
    
    self.newsLabel.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [self.newsLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    id newValue = change[NSKeyValueChangeNewKey];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([keyPath isEqualToString:@"speed"]){
            CALayer *layer = self.newsLabel.layer;
            layer.timeOffset = [layer convertTime:CACurrentMediaTime() toLayer:nil];
            layer.beginTime = CACurrentMediaTime();
            layer.speed = [newValue floatValue];
        }
        if([keyPath isEqualToString:@"textColor"]){
            self.newsLabel.textColor = newValue;
        }
        if([keyPath isEqualToString:@"font"]){
            self.newsLabel.font = newValue;
        }
    });
}

-(void)animation {
    self.isRunning = true;
    
    self.currentIndex += 1;
    
    if (self.currentIndex < self.items.count) {
        Item *item = self.items[self.currentIndex];
        NSString *news = [[NSString alloc] initWithFormat:@"【%@】 %@",item.title,item.itemDescription];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.newsLabel.text = news;
            [self.newsLabel sizeToFit];
            [self setAnimation];
        });
    }
    else {
        [self.delegate headLineNewsView:self animationEndedWith:self.items];
        NSArray<Item*> *items = [self.delegate nextItemsForView:self];
        if (!items || items.count <= 0) return;
        self.items = items;
        self.currentIndex = -1;
        [self animation];
    }
    
}

-(void)setAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.repeatCount = 0;
    animation.duration = self.newsLabel.frame.size.width / 200;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width + self.newsSpacing, 0)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(-self.newsLabel.frame.size.width, 0)];
    [animation setAdditive:true];
    [animation setRemovedOnCompletion:false];
    animation.fillMode = kCAFillModeBoth;
    animation.delegate = self;
    [self.newsLabel.layer setSpeed:self.speed];
    [self.newsLabel.layer addAnimation:animation forKey:@"animation"];
}

-(void)startAnimatingWith:(NSArray<Item*> *)items {
    if (!items || items.count <= 0) return;
    self.items = items;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animation];
    });
}

-(void)stopAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentIndex = -1;
        self.isRunning = false;
        self.newsLabel.text = @"";
        [self.newsLabel.layer removeAllAnimations];
    });
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if(self.isRunning){
        [self animation];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
