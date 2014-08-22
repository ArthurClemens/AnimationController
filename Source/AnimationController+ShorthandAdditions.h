// AnimationController+ShorthandAdditions.h
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

#import <QuartzCore/QuartzCore.h>
#import "AnimationController.h"

@interface AnimationController (ShorthandAdditions)

- (CABasicAnimation *)linearMoveAnimation:(CALayer*)layer
                                     from:(CGPoint)start
                                       to:(CGPoint)end
                           timingFunction:(id)timingFunction;
- (CAKeyframeAnimation *)pathAnimation:(CALayer*)layer
                                  path:(CGPathRef)path
                              keyTimes:(NSArray*)keyTimes
                       timingFunctions:(NSArray*)timings
                       calculationMode:(NSString*)calculationMode;
- (CAKeyframeAnimation *)propertyAnimation:(CALayer*)layer
                              propertyPath:(NSString*)propertyPath
                                    values:(NSArray*)values
                                  keyTimes:(NSArray*)keyTimes
                           timingFunctions:(NSArray*)timings
                           calculationMode:(NSString*)calculationMode;
- (CABasicAnimation *)rotateAnimation:(CALayer*)layer
                                 from:(float)angle
                                   to:(float)angle
                       timingFunction:(id)timingFunction;
- (CAKeyframeAnimation *)opacityAnimation:(CALayer*)layer
                                     from:(float)start
                                       to:(float)end
                           timingFunction:(id)timingFunction;
- (CAKeyframeAnimation *)scaleAnimation:(CALayer*)layer
                                   from:(float)start
                                     to:(float)end
                         timingFunction:(id)timingFunction;
- (CAKeyframeAnimation *)introBounceAnimation:(CALayer*)layer
                                   layerScale:(float)layerScale;
- (CAKeyframeAnimation *)attentionBounceAnimation:(CALayer*)layer
                                       layerScale:(float)layerScale;
- (void)centerLayer:(CALayer*)layer toLayer:(CALayer*)otherLayer;
- (CGRect)screenBounds;
- (CAMediaTimingFunction *)easeInOut;
- (CAMediaTimingFunction *)easeOut;
- (CAMediaTimingFunction *)easeIn;

@end
