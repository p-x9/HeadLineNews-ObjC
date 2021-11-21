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

-(void)setSpeed:(CGFloat)speed {
    if (_speed != speed) {
        _speed = speed;
        dispatch_async(dispatch_get_main_queue(), ^{
            CALayer *layer = self.newsLabel.layer;
            layer.timeOffset = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
            layer.beginTime = CACurrentMediaTime();
            layer.speed = speed;
        });
    }
}

-(void)setFont:(UIFont *)font {
    if (_font != font) {
        _font = font;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.newsLabel.font = font;
        });
    }
}

-(void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        _textColor = textColor;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.newsLabel.textColor = textColor;
        });
    }
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
