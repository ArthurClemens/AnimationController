
#import "AnimationController+ShorthandAdditions.h"

@implementation AnimationController (ShorthandAdditions)

- (CABasicAnimation *)linearMoveAnimation:(CALayer*)layer
                                     from:(CGPoint)start
                                       to:(CGPoint)end
                           timingFunction:(id)timingFunction
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [self setAnimationDefaults:layer animation:animation];
    animation.fromValue = [NSValue valueWithCGPoint:start];
    animation.toValue = [NSValue valueWithCGPoint:end];
    animation.timingFunction = timingFunction;
    return animation;
}

- (CAKeyframeAnimation *)pathAnimation:(CALayer*)layer
                                  path:(CGPathRef)path
                              keyTimes:(NSArray*)keyTimes
                       timingFunctions:(NSArray*)timings
                           calculationMode:(NSString*)calculationMode
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [self setAnimationDefaults:layer animation:animation];
    animation.path = path;
    if (keyTimes) animation.keyTimes = keyTimes;
    animation.timingFunctions = timings;
    if (calculationMode) {
        animation.calculationMode = calculationMode;
    } else {
        animation.calculationMode = kCAAnimationCubic;
    }
    return animation;
}

- (CAKeyframeAnimation *)propertyAnimation:(CALayer*)layer
                              propertyPath:(NSString*)propertyPath
                                    values:(NSArray*)values
                                  keyTimes:(NSArray*)keyTimes
                           timingFunctions:(NSArray*)timings
                           calculationMode:(NSString*)calculationMode
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:propertyPath];
    [self setAnimationDefaults:layer animation:animation];
    animation.values = values;
    if (keyTimes) animation.keyTimes = keyTimes;
    animation.timingFunctions = timings;
    if (calculationMode) animation.calculationMode = calculationMode;
    return animation;
}

- (CAKeyframeAnimation *)opacityAnimation:(CALayer*)layer
                                  from:(float)start
                                    to:(float)end
                        timingFunction:(id)timingFunction
{
    return [self propertyAnimation:layer
                      propertyPath:@"opacity"
                            values:@[@(start), @(end)]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:@[timingFunction]
                   calculationMode:kCAAnimationCubic];
}

- (CAKeyframeAnimation *)scaleAnimation:(CALayer*)layer
                                   from:(float)start
                                     to:(float)end
                         timingFunction:(id)timingFunction
{
    return [self propertyAnimation:layer
                      propertyPath:@"transform.scale"
                            values:@[@(start), @(end)]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:@[timingFunction]
                   calculationMode:kCAAnimationCubic];
}

/*
https://gist.github.com/samvermette/1691280
*/
- (CAKeyframeAnimation *)introBounceAnimation:(CALayer*)layer
                                   layerScale:(float)layerScale
{
    CAMediaTimingFunction* easeInOut = [self easeInOut];
    return [self propertyAnimation:layer
                      propertyPath:@"transform.scale"
                            values:@[
                                     @(0.05 * layerScale),
                                     @(1.11245 * layerScale),
                                     @(0.951807 * layerScale),
                                     @(1.0 * layerScale)
                                     ]
                          keyTimes:@[@0, @(4.0/9.0), @(4.0/9.0 + 5.0/18.0), @1.0]
                   timingFunctions:@[easeInOut, easeInOut, easeInOut, easeInOut]
                   calculationMode:nil];
}

- (CAKeyframeAnimation *)attentionBounceAnimation:(CALayer*)layer
                                       layerScale:(float)layerScale
{
    CAMediaTimingFunction* easeInOut = [self easeInOut];
    return [self propertyAnimation:layer
                      propertyPath:@"transform.scale"
                            values:@[
                                     @(1.0 * layerScale),
                                     @(1.3 * layerScale),
                                     @(.90 * layerScale),
                                     @(1.05 * layerScale),
                                     @(1.0 * layerScale)
                                     ]
                          keyTimes:@[@0, @0.25, @0.5, @0.75, @1.0]
                   timingFunctions:@[easeInOut, easeInOut, easeInOut, easeInOut]
                   calculationMode:kCAAnimationCubic];
}

- (void)centerLayer:(CALayer*)layer toLayer:(CALayer*)otherLayer
{
    float x = [otherLayer frame].size.width / 2;
    float y = [otherLayer frame].size.height / 2;
    layer.position = CGPointMake(x, y);
}

- (CAMediaTimingFunction *)easeInOut
{
    return [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
}

@end
