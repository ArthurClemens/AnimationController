
#import "MyAnimationController.h"

int BALL_COUNT = 13;
float BALL_RADIUS = 10.0;
NSMutableArray* balls;

@implementation MyAnimationController

- (id)initWithView:(UIView *)UIView
{
    self = [super initWithView:UIView];
    [self setup];
    return self;
}

- (void)setup
{
    self.view.backgroundColor = [UIColor blackColor];
    balls = [NSMutableArray array];
    self.tempo = 120; // 120 is the default
    self.tapBehavior = ACRestartAtEnd;
    [self create];
    [self prepare];
    self.actions = [self actions];
    [self start];
}

/*
Set up layer shapes (without position and time attributes).
*/
- (void)create
{
    self.layer = [self backgroundLayer]; // re-assigns the default view.layer
    
    for (NSUInteger i = 0, count = BALL_COUNT; i < count; i++) {
        CAShapeLayer* ball = [self createBall];
        [balls addObject:ball];
        [self.layer addSublayer:ball];
    }
    [self.view.layer addSublayer:self.layer];
}

- (NSArray*)actions
{
    // this list of actions looks more complicated than normal
    // because we are animating a list of layers
    
    NSMutableArray* actions = [NSMutableArray array];
    
    NSMutableArray* unisonFadeIn = [NSMutableArray array];
    for (NSUInteger i = 0, count = balls.count; i < count; i++) {
        [unisonFadeIn addObject: @{
            @"animation": ^(void) {
                return [self fadeIn:i];
            },
            @"duration" : @(self.half)
        }];
    }
    [actions addObject:@{
        @"unison":unisonFadeIn
    }];
    
    NSDictionary* rotate = @{
        @"animation": ^(void) {
            return [self rotate:1];
        },
        @"duration" : @(2 * self.two)
    };

    NSMutableArray* unisonMoveOut = [NSMutableArray array];
    for (NSUInteger i = 0, count = balls.count; i < count; i++) {
        [unisonMoveOut addObject: @{
            @"animation": ^(void) {
                return [self moveOut:i];
            },
            @"delay": @(self.sixteenth * (balls.count - i)),
            @"duration" : @(self.one)
        }];
    }
    [unisonMoveOut addObject: rotate];
    [actions addObject:@{
        @"unison": unisonMoveOut,
        // limit duration so that rotation can continue while next actions run
        @"duration": @(self.one + balls.count * self.sixteenth)
    }];
    
    NSMutableArray* unisonGrow = [NSMutableArray array];
    for (NSUInteger i = 0, count = balls.count; i < count; i++) {
        [unisonGrow addObject: @{
            @"animation": ^(void) {
                return [self grow:i];
            },
            @"delay": @(self.sixteenth * i),
            @"duration" : @(self.one)
        }];
    }
    [actions addObject:@{
        @"unison": unisonGrow
    }];
    
    NSMutableArray* unisonShrink = [NSMutableArray array];
    for (NSUInteger i = 0, count = balls.count; i < count; i++) {
        [unisonShrink addObject: @{
            @"animation": ^(void) {
                return [self shrink:i];
            },
            @"delay": @(self.sixteenth * (balls.count - i)),
            @"duration" : @(self.quarter)
        }];
    }
    [actions addObject:@{
        @"unison": unisonShrink
    }];

    NSMutableArray* unisonFadeOut = [NSMutableArray array];
    for (NSUInteger i = 0, count = balls.count; i < count; i++) {
        [unisonFadeOut addObject: @{
            @"animation": ^(void) {
                return [self fadeOut:i];
            },
            @"delay": @(self.sixteenth * i),
            @"duration" : @(self.half)
        }];
    }
    [actions addObject:@{
        @"unison":unisonFadeOut
    }];

    return actions;
}

/*
Set layers to their start state (position, opacity, etc.), so that the animation can be replayed from here.
*/
- (void)prepare
{
    [super prepare];
    double distanceFromCenter = 0.0;
    for (NSUInteger i = 0, count = balls.count; i < count; i++) {
        CAShapeLayer* ball = balls[i];
        [ball removeAllAnimations];
        ball.anchorPoint = CGPointMake(0, 0);
        ball.bounds = self.view.bounds;
        [self centerLayer:ball toLayer:self.layer];
        ball.opacity = 0.0;
        float angle = (i * 360.0 / balls.count) * M_PI / 180;
        [ball setValue:@(angle) forKeyPath:@"transform.rotation"];
        [ball setValue:@1.0 forKey:@"_scale"];
        [ball setValue:@(distanceFromCenter) forKey:@"_distance"];
    }
}

/*
Create a separate layer to draw everything on.
*/
- (CALayer *)backgroundLayer
{
    CALayer *layer = [CALayer layer];
    CGRect bounds = [self screenBounds];
    layer.frame = bounds;
    layer.bounds = bounds;
    return layer;
}

- (CAShapeLayer *)createBall
{
    CAShapeLayer* ball = [CAShapeLayer layer];
    ball.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-BALL_RADIUS, -BALL_RADIUS, 2.0*BALL_RADIUS, 2.0*BALL_RADIUS)
                                           cornerRadius:BALL_RADIUS].CGPath;
    ball.fillColor = [UIColor whiteColor].CGColor;
    return ball;
}

- (CAKeyframeAnimation *)fadeIn:(NSUInteger)index
{
    CAShapeLayer* ball = balls[index];
    return [self opacityAnimation:ball
                             from:0.0
                               to:1.0
                   timingFunction:[self easeOut]];
}

- (CAKeyframeAnimation *)fadeOut:(NSUInteger)index
{
    CAShapeLayer* ball = balls[index];
    return [self opacityAnimation:ball
                             from:1.0
                               to:0.0
                   timingFunction:[self easeOut]];
}

- (CAKeyframeAnimation *)scale:(CAShapeLayer*)layer from:(float)from to:(float)to
{
    [layer setValue:@(to) forKey:@"_scale"];
    return [self scaleAnimation:layer
                           from:from
                             to:to
                 timingFunction:[self easeOut]];
}

- (CAKeyframeAnimation *)grow:(NSUInteger)index
{
    CAShapeLayer* ball = balls[index];
    float current = [[ball valueForKey:@"_scale"] floatValue];
    float new = current * 2;
    return [self scale:ball from:current to:new];
}

- (CAKeyframeAnimation *)shrink:(NSUInteger)index
{
    CAShapeLayer* ball = balls[index];
    float current = [[ball valueForKey:@"_scale"] floatValue];
    float new = current / 4.0;
    return [self scale:ball from:current to:new];
}

- (CABasicAnimation *)rotate:(int)direction
{
    CABasicAnimation* animation = [self rotateAnimation:self.layer
                                                   from:0.0
                                                     to:(360 * direction * M_PI / 180.0)
                                         timingFunction:nil];
    animation.repeatCount = HUGE_VALF;
    return animation;
}

- (CAKeyframeAnimation *)moveAnchor:(CAShapeLayer*)layer from:(float)from to:(float)to
{
    [layer setValue:@(to) forKey:@"_distance"];
    NSValue* fromValue = [NSValue valueWithCGSize:CGSizeMake(0, from)];
    NSValue* toValue = [NSValue valueWithCGSize:CGSizeMake(0, to)];
    
    return [self propertyAnimation:layer
                      propertyPath:@"anchorPoint"
                            values:@[fromValue, toValue]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:@[[self easeOut]]
                   calculationMode:nil];
}

- (CAKeyframeAnimation *)moveOut:(NSUInteger)index
{
    CAShapeLayer* ball = balls[index];
    float current = [[ball valueForKey:@"_distance"] floatValue];
    float new = current + .1;
    return [self moveAnchor:ball from:current to:new];
}


@end
