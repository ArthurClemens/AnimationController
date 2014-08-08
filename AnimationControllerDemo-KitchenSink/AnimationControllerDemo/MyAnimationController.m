
#import "MyAnimationController.h"

CAShapeLayer* myLayer;
CALayer* repeatButtonLayer;
float BALL_RADIUS = 20.0;

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
    self.tapBehavior = ACRestartAtEnd;
    [self create];
    [self prepare];
    self.actions = [self actions];
    [self setOnAnimationComplete:^(void){
        NSLog(@"animation complete");
    }];
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
    self.layer = [self backgroundLayer]; // re-assigns the default self.view.layer
    myLayer = [self ballLayer];
    [self.layer addSublayer:myLayer];
    
    repeatButtonLayer = [self repeatButtonLayer];
    [self.layer addSublayer:repeatButtonLayer];
    
    [self.view.layer addSublayer:self.layer];
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

- (CAShapeLayer *)ballLayer
{
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-BALL_RADIUS, -BALL_RADIUS, 2.0*BALL_RADIUS, 2.0*BALL_RADIUS)
                                           cornerRadius:BALL_RADIUS].CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    return layer;
}

- (CATextLayer *)textIconWithText:(NSString*)text size:(float)size color:(UIColor*)color
{
    CATextLayer* layer = [CATextLayer layer];
    layer.font = (__bridge CFTypeRef)@"icomoon";
    layer.fontSize = size;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    layer.string = text;
    layer.foregroundColor = color.CGColor;
    layer.frame = CGRectMake(0, 0, size, size);
    return layer;
}

- (CATextLayer *)repeatButtonLayer
{
    float offWhite = .75;
    return [self textIconWithText:@"\ue600"
                             size:60.0
                            color:[UIColor colorWithRed:offWhite green:offWhite blue:offWhite alpha:1.0]];
}

/*
Create a list of animation actions
*/
- (NSArray*)actions
{
    return @[
        @{
            @"conditional": ^(void) {
                return self.count > 0;
            },
            @"animation": ^(void) {
                return [self hideRepeatButton];
            },
            @"duration" : @(self.quarter)
        },
        @{
            @"unison": @[
                @{
                    @"animation": [self fadeIn],
                    @"duration" : @(self.one)
                },
                @{
                    @"animation": ^(void) {
                        return [self resize];
                    },
                    @"duration" : @(self.one)
                }
            ]
        },
        @{
            @"animation": ^(void) {
                return [self colorize];
            },
            @"duration" : @(self.half)
        },
        @{
            @"name": @"moving",
            @"unison": @[
                @{
                    @"animation": ^(void) {
                        return [self circular];
                    },
                    @"duration" : @(self.one)
                },
                @{
                    @"animation": ^(void) {
                        return [self resize];
                    },
                    @"duration" : @(self.one)
                }
            ]
        },
        @{
            @"jump": @"moving",
            @"repeat": @3,
        },
        @{
            @"unison": @[
                @{
                    @"animation": [self fadeOut],
                    @"duration" : @(self.one)
                },
                @{
                    @"animation": ^(void) {
                        return [self resize];
                    },
                    @"duration" : @(self.one)
                },
                @{
                    @"animation": [self showRepeatButton],
                    @"delay": @(self.half),
                    @"duration" : @(self.one)
                }
            ]
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
    [myLayer setValue:@(1.0) forKey:@"_scale"];
    
    [self centerLayer:repeatButtonLayer toLayer:self.layer];
    repeatButtonLayer.opacity = 0;
}

- (CAKeyframeAnimation *)fadeIn
{
    return [self opacityAnimation:myLayer
                             from:0.0
                               to:1.0
                   timingFunction:[self easeInOut]];
}

- (CAKeyframeAnimation *)fadeOut
{
    return [self opacityAnimation:myLayer
                             from:1.0
                               to:0.0
                   timingFunction:[self easeInOut]];
}
        
- (CAKeyframeAnimation *)resize
{
    float current = [[myLayer valueForKey:@"_scale"] floatValue];
    float new = current * [self randomInRangeMin:5 max:20] * 0.1;
    [myLayer setValue:@(new) forKey:@"_scale"];
    return [self scaleAnimation:myLayer
                           from:current
                             to:new
                 timingFunction:nil];
}

- (CAKeyframeAnimation *)colorize
{
    id from = (id)[myLayer valueForKey:@"fillColor"];
    id to = (id)[UIColor redColor].CGColor;
    
    return [self propertyAnimation:myLayer
                      propertyPath:@"fillColor"
                            values:@[from, to]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:@[[self easeInOut]]
                   calculationMode:nil];
}

- (CAKeyframeAnimation *)circular
{
    float currentPosX, currentPosY = 0.0;
    float posX = 0.0;
    float posY = 0.0;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,
                      NULL,
                      currentPosX,
                      currentPosY
                      );
    CGPathAddCurveToPoint(path,
                          NULL,
                          posX + [self randomInRangeMin:200 max:300] * [self randomFlip],
                          posY + [self randomInRangeMin:250 max:350] * [self randomFlip],
                          posX + [self randomInRangeMin:400 max:500] * [self randomFlip],
                          posY + [self randomInRangeMin:50 max:150] * [self randomFlip],
                          posX,
                          posY
                          );
    NSValue* from = [NSValue valueWithCGSize:CGSizeMake(currentPosX, currentPosY)];
    NSValue* to = [NSValue valueWithCGSize:CGSizeMake(posX, posY)];
    CAKeyframeAnimation* animation = [self propertyAnimation:myLayer
                                                propertyPath:@"transform.translation"
                                                      values:@[from, to]
                                                    keyTimes:@[@0.0, @1.0]
                                             timingFunctions:nil
                                             calculationMode:nil];
    animation.path = path;
    return animation;
}

- (CAKeyframeAnimation *)showRepeatButton
{
    return [self opacityAnimation:repeatButtonLayer
                             from:0.0
                               to:1.0
                   timingFunction:[self easeInOut]];
}

- (CAKeyframeAnimation *)hideRepeatButton
{
    return [self opacityAnimation:repeatButtonLayer
                             from:1.0
                               to:0.0
                   timingFunction:[self easeInOut]];
}

- (float)randomInRangeMin:(float)min max:(float)max
{
    int random = abs(min) + arc4random_uniform(abs(max) - abs(min));
    return (float)random;
}

- (int)randomFlip
{
    return (arc4random_uniform(101) > 55) ? 1 : -1;
}

@end
