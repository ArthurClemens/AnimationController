
#import "MyAnimationController.h"

const float CUBE_SIZE = 100; // for building the cube

CATransformLayer* cubeLayer;
CALayer* repeatButtonLayer;
float size;
float rotationX;
float rotationY;
float scaleX;
float scaleY;
float layerScale;
float posX;
float posY;

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
    self.tempo = 120; // 120 is the default
    self.tapBehavior = ACRestartAtEnd;
    [self create];
    [self prepare];
    self.actions = [self actions];
    [self start];
}

- (void)cleanup
{
    [cubeLayer removeFromSuperlayer];
    [super cleanup];
}

/*
Set up layer shapes (without position and time attributes).
*/
- (void)create
{
    self.layer = [self backgroundLayer]; // re-assigns the default self.view.layer
    cubeLayer = [self cubeLayer];
    [self.layer addSublayer:cubeLayer];
    
    repeatButtonLayer = [self repeatButtonLayer];
    [self.layer addSublayer:repeatButtonLayer];
    
    [self.view.layer addSublayer:self.layer];
}

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
            @"delay": @(self.half),
            @"unison": @[
                // fall
                @{
                    @"animation": ^(void) {
                        return [self fallY];
                    },
                    @"duration" : @(self.half),
                },
                @{
                    @"animation": ^(void) {
                        return [self fallW];
                    },
                    @"duration" : @(self.half),
                },
                @{
                    @"animation": ^(void) {
                        return [self fallH];
                    },
                    @"duration" : @(self.half),
                },
                // slap to ground
                @{
                    @"animation": ^(void) {
                        return [self slapW];
                    },
                    @"delay" : @(self.half - self.sixteenth*.95),
                    @"duration" : @(self.eighth),
                },
                @{
                    @"animation": ^(void) {
                        return [self slapH];
                    },
                    @"delay" : @(self.half - self.sixteenth*.95),
                    @"duration" : @(self.eighth),
                },
                @{
                    @"animation": ^(void) {
                        return [self slapY];
                    },
                    @"delay" : @(self.half - self.sixteenth*.95),
                    @"duration" : @(self.eighth),
                }
            ]
        },
        @{
            @"name": @"rebounce",
            @"unison": @[
                // rebounce
                @{
                    @"animation": ^(void) {
                        return [self bounceW];
                    },
                    @"duration" : @(self.quarter)
                },
                @{
                    @"animation": ^(void) {
                        return [self bounceH];
                    },
                    @"duration" : @(self.quarter)
                },
                @{
                    @"animation": ^(void) {
                        return [self bounceY];
                    },
                    @"duration" : @(self.quarter)
                },
                // straight up
                @{
                    @"animation": ^(void) {
                        return [self straightUpW];
                    },
                    @"delay" : @(self.sixteenth),
                    @"duration" : @(self.sixteenth)
                },
                @{
                    @"animation": ^(void) {
                        return [self straightUpH];
                    },
                    @"delay" : @(self.sixteenth),
                    @"duration" : @(self.sixteenth)
                },
                @{
                    @"animation": ^(void) {
                        return [self straightUpY];
                    },
                    @"delay" : @(self.sixteenth),
                    @"duration" : @(self.sixteenth)
                },
                // float up
                @{
                    @"animation": ^(void) {
                        return [self floatW];
                    },
                    @"delay" : @(self.eighth),
                    @"duration" : @(self.sixteenth)
                },
                @{
                    @"animation": ^(void) {
                        return [self floatH];
                    },
                    @"delay" : @(self.eighth),
                    @"duration" : @(self.sixteenth)
                },
                @{
                    @"animation": ^(void) {
                        return [self floatY];
                    },
                    @"delay" : @(self.eighth),
                    @"duration" : @(self.sixteenth)
                },
                @{
                    @"animation": ^(void) {
                        return [self floatR];
                    },
                    @"delay" : @(self.eighth),
                    @"duration" : @(self.quarter)
                },
                @{
                    @"animation": ^(void) {
                        return [self floatRX];
                    },
                    @"delay" : @(self.eighth),
                    @"duration" : @(self.quarter)
                }
            ]
        },
        @{
            @"unison": @[
                // fall from high position
                @{
                    @"animation": ^(void) {
                        return [self fallHighW];
                    },
                    @"duration" : @(self.eighth),
                },
                @{
                    @"animation": ^(void) {
                        return [self fallHighH];
                    },
                    @"duration" : @(self.eighth),
                },
                @{
                    @"animation": ^(void) {
                        return [self fallHighY];
                    },
                    @"duration" : @(self.eighth),
                },
                @{
                    @"animation": ^(void) {
                        return [self fallHighR];
                    },
                    @"duration" : @(self.eighth * 2),
                },
                // slap to ground
                @{
                    @"animation": ^(void) {
                        return [self slapW];
                    },
                    @"delay" : @(self.eighth - self.sixteenth*.95),
                    @"duration" : @(self.eighth),
                },
                @{
                    @"animation": ^(void) {
                        return [self slapH];
                    },
                    @"delay" : @(self.eighth - self.sixteenth*.95),
                    @"duration" : @(self.eighth),
                },
                @{
                    @"animation": ^(void) {
                        return [self slapY];
                    },
                    @"delay" : @(self.eighth - self.sixteenth*.95),
                    @"duration" : @(self.eighth),
                },
                @{
                    @"animation": ^(void) {
                        return [self slapRX];
                    },
                    @"delay" : @(self.eighth - self.sixteenth*.95),
                    @"duration" : @(self.eighth),
                }
            ]
        },
        @{
            @"jump": @"rebounce",
            @"repeat": @3
        },
        @{
            @"unison": @[
                // final rebounce
                @{
                    @"animation": ^(void) {
                        return [self bounceW];
                    },
                    @"duration" : @(self.quarter)
                },
                @{
                    @"animation": ^(void) {
                        return [self bounceH];
                    },
                    @"duration" : @(self.quarter)
                },
                @{
                    @"animation": ^(void) {
                        return [self bounceY];
                    },
                    @"duration" : @(self.quarter)
                },
                @{
                    @"animation": ^(void) {
                        return [self bounceR];
                    },
                    @"duration" : @(self.quarter)
                },
                @{
                    @"animation": ^(void) {
                        return [self bounceRX];
                    },
                    @"duration" : @(self.quarter)
                }
            ]
        },
        @{
            @"delay": @(self.half),
            @"unison": @[
                @{
                    @"animation": ^(void) {
                        return [self floatToTopPos];
                    },
                    @"duration" : @(self.two)
                },
                @{
                    @"animation": ^(void) {
                        return [self floatToTopRX];
                    },
                    @"duration" : @(self.two)
                },
                @{
                    @"animation": ^(void) {
                        return [self floatToTopRY];
                    },
                    @"duration" : @(self.two)
                },
                @{
                    @"animation": ^(void) {
                        return [self showRepeatButton];
                    },
                    @"delay": @(self.one),
                    @"duration" : @(self.one)
                },
                @{
                    @"animation": ^(void) {
                        return [self rotateRepeatButton];
                    },
                    @"delay": @(self.one),
                    @"duration" : @(self.one)
                }
            ],
            @"duration": @(self.one)
        }
    ];
}

/*
Set layers to their start state (position, opacity, etc.).
*/
- (void)prepare
{
    [super prepare];
    [cubeLayer removeAllAnimations];
    CGRect screenBounds = [self screenBounds];

    size = screenBounds.size.height / 10;
    layerScale = 0.5;
    rotationX = 0.0;
    rotationY = 0.0;
    scaleX = 1.0 * layerScale;
    scaleY = 1.0 * layerScale;
    posX = 0.0;
    cubeLayer.anchorPoint = CGPointMake((CGFloat)0, (CGFloat)0);
	cubeLayer.bounds = screenBounds;
    [self centerLayer:cubeLayer toLayer:self.layer];
    cubeLayer.transform = CATransform3DMakeScale(layerScale, layerScale, layerScale);

    if (self.count > 0) {
        posY = -3.0 * size;
        [cubeLayer setValue:@(posY) forKeyPath:@"transform.translation.y"];
    } else {
        posY = 0.0;
    }
    
    [self centerLayer:repeatButtonLayer toLayer:self.layer];
    repeatButtonLayer.opacity = 0;
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
Taken from http://www.cocoanetics.com/2012/08/cubed-coreanimation-conundrum/
*/
- (CATransformLayer *)cubeLayer
{
    float near = 255.0 / 255.0;
    float side = 190.0 / 255.0;
    float top = 130.0 / 255.0;
    float bottom = 130.0 / 255.0;
    float far = 100.0 / 255.0;
    UIColor* FAR_COLOR = [UIColor colorWithRed:far green:far blue:far alpha:1.0];
    UIColor* LEFT_COLOR = [UIColor colorWithRed:side green:side blue:side alpha:1.0];
    UIColor* TOP_COLOR = [UIColor colorWithRed:top green:top blue:top alpha:1.0];
    UIColor* BOTTOM_COLOR = [UIColor colorWithRed:bottom green:bottom blue:bottom alpha:1.0];
    UIColor* RIGHT_COLOR = [UIColor colorWithRed:side green:side blue:side alpha:1.0];
    UIColor* NEAR_COLOR = [UIColor colorWithRed:near green:near blue:near alpha:1.0];

    CATransformLayer* baseLayer = [CATransformLayer layer];
    
    // far end
    CALayer* farLayer = [CALayer layer];
	farLayer.backgroundColor = FAR_COLOR.CGColor;
	farLayer.frame = CGRectMake(0, 0, CUBE_SIZE, CUBE_SIZE);
	farLayer.position = CGPointMake(0, 0);
	[baseLayer addSublayer:farLayer];
    
    // left
    CALayer* leftLayer = [CALayer layer];
	leftLayer.backgroundColor = LEFT_COLOR.CGColor;
	leftLayer.bounds = CGRectMake(0, 0, CUBE_SIZE, CUBE_SIZE);
	leftLayer.anchorPoint = CGPointMake(1, 0.5);
	leftLayer.position = CGPointMake(-CUBE_SIZE/2, 0);
	[baseLayer addSublayer:leftLayer];
    
    // top
    CALayer* topLayer = [CALayer layer];
	topLayer.backgroundColor = TOP_COLOR.CGColor;
	topLayer.bounds = CGRectMake(0, 0, CUBE_SIZE, CUBE_SIZE);
	topLayer.anchorPoint = CGPointMake(0.5, 1);
	topLayer.position = CGPointMake(0, -CUBE_SIZE/2);
	[baseLayer addSublayer:topLayer];
    
    // bottom
    CALayer* bottomLayer = [CALayer layer];
	bottomLayer.backgroundColor = BOTTOM_COLOR.CGColor;
	bottomLayer.bounds = CGRectMake(0, 0, CUBE_SIZE, CUBE_SIZE);
	bottomLayer.anchorPoint = CGPointMake(0.5, 0);
	bottomLayer.position = CGPointMake(0, CUBE_SIZE/2);
	[baseLayer addSublayer:bottomLayer];
    
    // right
    CALayer* rightLayer = [CATransformLayer layer];
	rightLayer.bounds = CGRectMake(0, 0, CUBE_SIZE, CUBE_SIZE);
	rightLayer.anchorPoint = CGPointMake(0, 0.5); // left
	rightLayer.position = CGPointMake(CUBE_SIZE/2, 0);
	[baseLayer addSublayer:rightLayer];
    
	CALayer *rightSolidLayer = [CALayer layer];
	rightSolidLayer.backgroundColor = RIGHT_COLOR.CGColor;
	rightSolidLayer.bounds = CGRectMake(0, 0, CUBE_SIZE, CUBE_SIZE);
	rightSolidLayer.anchorPoint = CGPointMake(0, 0);
	rightSolidLayer.position = CGPointMake(0,0);
	[rightLayer addSublayer:rightSolidLayer];
    
    // near
    CALayer* nearLayer = [CALayer layer];
	nearLayer.backgroundColor = NEAR_COLOR.CGColor;
	nearLayer.bounds = CGRectMake(0, 0, CUBE_SIZE, CUBE_SIZE);
	nearLayer.anchorPoint = CGPointMake(0, 0.5);
	nearLayer.position = CGPointMake(CUBE_SIZE, CUBE_SIZE/2);
	[rightLayer addSublayer:nearLayer];
    
    CATransform3D initialTransform = baseLayer.sublayerTransform;
	initialTransform.m34 = 1.0 / -1200;
	baseLayer.sublayerTransform = initialTransform;
    
    // transform planes to cube
    rightLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
    leftLayer.transform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
    topLayer.transform = CATransform3DMakeRotation(-M_PI_2, 1, 0, 0);
    bottomLayer.transform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
    nearLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
    
    return baseLayer;
}

- (CAKeyframeAnimation *)animateY:(float)y timing:(CAMediaTimingFunction*)timing
{
    float currentPosY = posY;
    posY = y;
    return [self propertyAnimation:cubeLayer
                      propertyPath:@"transform.translation.y"
                            values:@[@(currentPosY), @(posY)]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:@[timing]
                   calculationMode:nil];
}

- (CAKeyframeAnimation *)animateScaleX:(float)sx timing:(CAMediaTimingFunction*)timing
{
    float currentScaleX = scaleX;
    scaleX = sx;
    return [self propertyAnimation:cubeLayer
                      propertyPath:@"transform.scale.x"
                            values:@[@(currentScaleX), @(scaleX)]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:@[timing]
                   calculationMode:nil];
}

- (CAKeyframeAnimation *)animateScaleY:(float)sy timing:(CAMediaTimingFunction*)timing
{
    float currentScaleY = scaleY;
    scaleY = sy;
    return [self propertyAnimation:cubeLayer
                      propertyPath:@"transform.scale.y"
                            values:@[@(currentScaleY), @(scaleY)]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:@[timing]
                   calculationMode:nil];
}

- (CAKeyframeAnimation *)animateRotationX:(float)rx timing:(CAMediaTimingFunction*)timing
{
    float currentRotationX = rotationX;
    rotationX = rx;
    return [self propertyAnimation:cubeLayer
                      propertyPath:@"transform.rotation.x"
                            values:@[@(currentRotationX), @(rotationX)]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:@[timing]
                   calculationMode:nil];
}

- (CAKeyframeAnimation *)animateRotationY:(float)ry timing:(CAMediaTimingFunction*)timing
{
    float currentRotationY = rotationY;
    rotationY = ry;
    return [self propertyAnimation:cubeLayer
                      propertyPath:@"transform.rotation.y"
                            values:@[@(currentRotationY), @(rotationY)]
                          keyTimes:@[@0.0, @1.0]
                   timingFunctions:@[timing]
                   calculationMode:nil];
}

- (CAKeyframeAnimation *)fallY
{
    float y = 2 * size;
    return [self animateY:y timing:[self easeIn]];
}

- (CAKeyframeAnimation *)fallW
{
    return [self animateScaleX:1.0/3.0 timing:[self easeIn]];
}

- (CAKeyframeAnimation *)fallH
{
    return [self animateScaleY:3.0 timing:[self easeIn]];
}

- (CAKeyframeAnimation *)slapW
{
    return [self animateScaleX:4.0 timing:[self easeOut]];
}

- (CAKeyframeAnimation *)slapH
{
    return [self animateScaleY:1.0/8.0 timing:[self easeOut]];
}

- (CAKeyframeAnimation *)slapY
{
    float y = (3.6 * size);
    return [self animateY:y timing:[self easeOut]];
}

- (CAKeyframeAnimation *)slapRX
{
    float random = [self randomXRotationInRangeMin:7 max:10 tilt:-1];
    return [self animateRotationX:random timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)bounceW
{
    return [self resetScaleX:[self easeInOut]];
}

- (CAKeyframeAnimation *)bounceH
{
    return [self resetScaleY:[self easeInOut]];
}

- (CAKeyframeAnimation *)bounceY
{
    float y = (3.6 * size);
    return [self animateY:y timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)bounceR
{
    return [self resetRotationY:[self easeInOut]];
}

- (CAKeyframeAnimation *)bounceRX
{
    return [self resetRotationX:[self easeInOut]];
}

- (CAKeyframeAnimation *)straightUpW
{
    return [self animateScaleX:1.0/10.0 timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)straightUpH
{
    return [self animateScaleY:5.0 timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)straightUpY
{
    float y = -size/2;
    return [self animateY:y timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)floatW
{
    return [self resetScaleX:[self easeInOut]];
}

- (CAKeyframeAnimation *)floatH
{
    return [self resetScaleY:[self easeInOut]];
}

- (CAKeyframeAnimation *)floatY
{
    float y = -3 * size;
    return [self animateY:y timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)floatR
{
    float random = [self randomYRotationInRangeMin:30 max:45];
    return [self animateRotationY:random timing:[self easeOut]];
}

- (CAKeyframeAnimation *)floatRX
{
    float random = [self randomXRotationInRangeMin:7 max:10 tilt:1];
    return [self animateRotationX:random timing:[self easeOut]];
}

- (CAKeyframeAnimation *)fallHighW
{
    return [self animateScaleX:1.0/4.0 timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)fallHighH
{
    return [self animateScaleY:4.0 timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)fallHighY
{
    float y = 1 * size;
    return [self animateY:y timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)fallHighR
{
    float random = [self randomYRotationInRangeMin:5 max:20];
    return [self animateRotationY:random timing:[self easeInOut]];
}

- (CAKeyframeAnimation *)resetScaleX:(CAMediaTimingFunction*)timing
{
    return [self animateScaleX:layerScale timing:timing];
}

- (CAKeyframeAnimation *)resetScaleY:(CAMediaTimingFunction*)timing
{
    return [self animateScaleY:layerScale timing:timing];
}

- (CAKeyframeAnimation *)resetRotationX:(CAMediaTimingFunction*)timing
{
    return [self animateRotationX:0 timing:timing];
}

- (CAKeyframeAnimation *)resetRotationY:(CAMediaTimingFunction*)timing
{
    return [self animateRotationY:0 timing:timing];
}

- (CAKeyframeAnimation *)floatToTopPos
{
    float currentPosX = posX;
    posX = 0.0;
    
    float currentPosY = posY;
    posY = -3 * size;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,
                      NULL,
                      currentPosX,
                      currentPosY
                      );
    CGPathAddCurveToPoint(path,
                          NULL,
                          posX + [self randomInRangeMin:200 max:300],
                          posY + [self randomInRangeMin:250 max:350],
                          posX - [self randomInRangeMin:400 max:500],
                          posY + [self randomInRangeMin:50 max:150],
                          posX,
                          posY
                          );
    NSValue* from = [NSValue valueWithCGSize:CGSizeMake(currentPosX, currentPosY)];
    NSValue* to = [NSValue valueWithCGSize:CGSizeMake(posX, posY)];
    CAKeyframeAnimation* animation = [self propertyAnimation:cubeLayer
                                                propertyPath:@"transform.translation"
                                                      values:@[from, to]
                                                    keyTimes:@[@0.0, @1.0]
                                             timingFunctions:@[[self easeInOut]]
                                             calculationMode:nil];
    animation.path = path;
    return animation;
}

- (CAKeyframeAnimation *)floatToTopRX
{
    float currentRotationX = rotationX;
    rotationX = 0.0;
    float currentRotationY = rotationY;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,
                      NULL,
                      currentRotationX,
                      currentRotationY
                      );
    CGPathAddCurveToPoint(path,
                          NULL,
                          rotationX + [self randomXRotationInRangeMin:-80 max:80 tilt:1],
                          rotationY + [self randomYRotationInRangeMin:-80 max:80],
                          rotationX + [self randomXRotationInRangeMin:-80 max:80 tilt:-1],
                          rotationY + [self randomYRotationInRangeMin:-80 max:80],
                          rotationX,
                          rotationY
                          );
    NSValue* from = [NSValue valueWithCGSize:CGSizeMake(currentRotationX, currentRotationY)];
    NSValue* to = [NSValue valueWithCGSize:CGSizeMake(rotationX, rotationY)];
    CAKeyframeAnimation* animation = [self propertyAnimation:cubeLayer
                                                propertyPath:@"transform.rotation.x"
                                                      values:@[from, to]
                                                    keyTimes:@[@0.0, @1.0]
                                             timingFunctions:@[[self easeInOut]]
                                             calculationMode:nil];
    animation.path = path;
    return animation;

}

- (CAKeyframeAnimation *)floatToTopRY
{
    float currentRotationX = rotationX;
    float currentRotationY = rotationY;
    rotationY = 0.0;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,
                      NULL,
                      currentRotationX,
                      currentRotationY
                      );
    CGPathAddCurveToPoint(path,
                          NULL,
                          rotationX + [self randomXRotationInRangeMin:-80 max:80 tilt:1],
                          rotationY + [self randomYRotationInRangeMin:-80 max:80],
                          rotationX + [self randomXRotationInRangeMin:-80 max:80 tilt:-1],
                          rotationY + [self randomYRotationInRangeMin:-80 max:80],
                          rotationX,
                          rotationY
                          );
    NSValue* from = [NSValue valueWithCGSize:CGSizeMake(currentRotationX, currentRotationY)];
    NSValue* to = [NSValue valueWithCGSize:CGSizeMake(rotationX, rotationY)];
    CAKeyframeAnimation* animation = [self propertyAnimation:cubeLayer
                                                propertyPath:@"transform.rotation.y"
                                                      values:@[from, to]
                                                    keyTimes:@[@0.0, @1.0]
                                             timingFunctions:@[[self easeInOut]]
                                             calculationMode:nil];
    animation.path = path;
    return animation;
    
}

- (float)randomXRotationInRangeMin:(float)min max:(float)max tilt:(int)tilt
{
    float degrees = min + arc4random_uniform(max-min);
    degrees *= tilt;
    return degrees * M_PI / 180;
}

- (float)randomYRotationInRangeMin:(float)min max:(float)max
{
    float degrees = [self randomInRangeMin:min max:max];
    if (arc4random_uniform(11) > 5) degrees = -degrees;
    return degrees * M_PI / 180.0;
}

- (float)randomInRangeMin:(float)min max:(float)max
{
    int random = abs(min) + arc4random_uniform(abs(max) - abs(min));
    return (float)random;
}

- (CAKeyframeAnimation *)showRepeatButton
{
    return [self opacityAnimation:repeatButtonLayer
                             from:0.0
                               to:1.0
                   timingFunction:[self easeInOut]];
}

- (CAKeyframeAnimation *)rotateRepeatButton
{
    return [self propertyAnimation:repeatButtonLayer
                      propertyPath:@"transform.rotation"
                            values:@[@(0), @(-180 * M_PI / 180)]
                                 keyTimes:@[@0.0, @1.0]
                          timingFunctions:@[[self easeInOut]]
                          calculationMode:nil];
}

- (CAKeyframeAnimation *)hideRepeatButton
{
    return [self opacityAnimation:repeatButtonLayer
                             from:1.0
                               to:0.0
                   timingFunction:[self easeInOut]];
}

@end
