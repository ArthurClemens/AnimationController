// AnimationController+ShorthandAdditions.m
// https://github.com/ArthurClemens/AnimationController
//
// Copyright (c) 2014 Arthur Clemens, arthurclemens@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

- (CABasicAnimation *)rotateAnimation:(CALayer*)layer
                                 from:(float)fromAngle
                                   to:(float)toAngle
                       timingFunction:(id)timingFunction
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [self setAnimationDefaults:layer animation:animation];
    CATransform3D rotationTransform = CATransform3DRotate(layer.transform, toAngle, 0.0, 0.0, 1.0);
    layer.transform = rotationTransform;
    animation.fromValue = [NSNumber numberWithFloat:fromAngle];
    animation.toValue = [NSNumber numberWithFloat:toAngle];
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
    if (timings) animation.timingFunctions = timings;
    if (calculationMode) animation.calculationMode = calculationMode;
    return animation;
}

- (CAKeyframeAnimation *)opacityAnimation:(CALayer*)layer
                                  from:(float)start
                                    to:(float)end
                        timingFunction:(id)timingFunction
{
    NSArray* timingFunctions;
    if (timingFunction) timingFunctions = @[timingFunction];
    return [self propertyAnimation:layer
                      propertyPath:@"opacity"
                            values:@[@(start), @(end)]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:timingFunctions
                   calculationMode:kCAAnimationCubic];
}

- (CAKeyframeAnimation *)scaleAnimation:(CALayer*)layer
                                   from:(float)start
                                     to:(float)end
                         timingFunction:(id)timingFunction
{
    NSArray* timingFunctions;
    if (timingFunction) timingFunctions = @[timingFunction];
    return [self propertyAnimation:layer
                      propertyPath:@"transform.scale"
                            values:@[@(start), @(end)]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:timingFunctions
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

- (void)centerLayer:(CALayer*)layer
            toLayer:(CALayer*)otherLayer
{
    float x = [otherLayer frame].size.width / 2;
    float y = [otherLayer frame].size.height / 2;
    layer.position = CGPointMake(x, y);
}

- (CGRect)screenBounds
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(screenBounds);
    CGFloat height = CGRectGetHeight(screenBounds);
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(width, height);
    } else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        screenBounds.size = CGSizeMake(height, width);
    }
    return screenBounds;
}

- (CAMediaTimingFunction *)easeInOut
{
    return [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
}

- (CAMediaTimingFunction *)easeOut
{
    return [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
}

- (CAMediaTimingFunction *)easeIn
{
    return [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
}

@end
