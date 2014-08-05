
#import "MyAnimationController.h"

CAShapeLayer* myLayer;

@implementation MyAnimationController

- (id)initWithView:(UIView *)UIView
{
    self = [super initWithView:UIView];
    [self setup];
    return self;
}

/*
Set up all things animation related
*/
- (void)setup
{
    self.view.backgroundColor = [UIColor blackColor];
    self.tempo = 120;
    [self create];
    [self prepare];
    self.actions = [self actions];
    [self start];
}

/*
Clean up after use
*/
- (void)cleanup
{
    [myLayer removeFromSuperlayer];
    [super cleanup];
}

/*
Set up layer shapes (without position and time attributes).
*/
- (void)create
{
    myLayer = [self createLayer];
    self.layer.frame = [self screenBounds];
    self.layer.bounds = [self screenBounds];
    [self.layer addSublayer:myLayer];
}

- (CAShapeLayer *)createLayer
{
    CAShapeLayer* layer = [CAShapeLayer layer];
    float size = 100.0;
    layer.path = [UIBezierPath bezierPathWithRect:CGRectMake(-size/2, -size/2, size, size)].CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    return layer;
}

/*
Create a list of animation actions
*/
- (NSArray*)actions
{
    return @[
        @{
            @"animation": [self fadeIn],
            @"delay": @(self.half),
            @"duration" : @(self.one)
        },
        @{
            @"animation": [self fadeOut],
            @"delay": @(self.half),
            @"duration" : @(self.one)
        }
    ];
}

/*
Set layers to their start state (position, opacity, etc.), so that the animation can be replayed from here.
*/
- (void)prepare
{
    [super prepare];
    [myLayer removeAllAnimations];
    [self centerLayer:myLayer toLayer:self.layer];
    myLayer.opacity = 0.0;
}

- (CAKeyframeAnimation *)fadeIn
{
    return [self opacityAnimation:myLayer
                             from:0.0
                               to:1.0
                   timingFunction:[self easeIn]];
}

- (CAKeyframeAnimation *)fadeOut
{
    return [self opacityAnimation:myLayer
                             from:1.0
                               to:0.0
                   timingFunction:[self easeOut]];
}

@end
