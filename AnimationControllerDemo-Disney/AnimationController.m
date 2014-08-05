
#import "AnimationController.h"
#import <QuartzCore/QuartzCore.h>

typedef CAAnimation* (^AnimationBlockType)(void);
typedef void (^FunctionBlockType)(void);
typedef BOOL (^ConditionalBlockType)(void);

@implementation AnimationController

- (id)initWithView:(UIView *)UIView
{
    self = [super init];
    if (self) {
        self.view = UIView;
        self.tempo = DEFAULT_TEMPO;
        self.playCount = 0;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:singleTap];
    }
    return self;
}

- (void)resetLayers {
    [self.mainLayer removeAllAnimations];
}

- (void)restart {
    [self resetLayers];
    [self initAnimationData];
    [self nextAnimation];
}

- (void)processAnimations:(NSArray *)animationData
{
    self.animationData = animationData;
    [self initAnimationData];
}

- (void)initAnimationData
{
    self.paused = NO;
    self.completed = NO;
    _runningAnimations = [NSMutableDictionary new];
    _workingAnimationData = [NSMutableArray arrayWithArray:self.animationData];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateRecognized) return;
    if (self.completed) {
        [self restart];
    } else {
        self.paused = !self.paused;
        if (self.paused) {
            [self pauseAnimations];
        } else {
            [self resumeAnimations];
        }
    }
}

- (void)pauseAnimations
{
    for (NSString* key in _runningAnimations) {
        CAAnimation* animation = _runningAnimations[key][@"animation"];
        CALayer *layer = [animation valueForKey:nil];
        CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
    }
}

- (void)resumeAnimations
{
    for (NSString* key in _runningAnimations) {
        CAAnimation* animation = _runningAnimations[key][@"animation"];
        CALayer *layer = [animation valueForKey:nil];
        CFTimeInterval pausedTime = [layer timeOffset];
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        layer.beginTime = timeSincePause;
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    NSString* name = [animation valueForKey:@"name"];
    [self animationDone:name];
}

- (void)animationDone:(NSString *)name
{
    if (self.paused || self.completed) {
        return;
    }
    
    // By exception the action of type function is called right after the (dummy) animation
    // so that delay can be used as any other action
    NSDictionary* data = _runningAnimations[name];
    if (data[@"function"]) {
        FunctionBlockType block = data[@"function"];
        block();
    }
    
    BOOL isSequential = [data[@"data"][@"isSequential"] boolValue];
    
    [_runningAnimations removeObjectForKey:name];
    
    if (_workingAnimationData.count == 0) {
        [self finish];
    }
    
    if (isSequential) {
        [self nextAnimation];
    }
}

- (void)nextAnimation
{
    if (self.paused || self.completed) {
        return;
    }
    NSDictionary* data = _workingAnimationData[0];
    [_workingAnimationData removeObjectAtIndex:0];
    [self maybeHandleAnimationData:data];
}

- (void)finish
{
    self.completed = true;
    self.playCount++;
}


- (void)maybeHandleAnimationData:(NSDictionary*)data
{
    if (data[@"conditional"]) {
        ConditionalBlockType block = data[@"conditional"];
        BOOL result = block();
        if (result) {
            [self handleAnimationData:data];
        } else {
            [self nextAnimation];
        }
    } else {
        [self handleAnimationData:data];
    }
}

- (void)handleAnimationData:(NSDictionary*)data
{
    if (data[@"unison"]) {
        [self handleUnisonAnimation:data];
    } else if (data[@"animation"]) {
        [self handleAnimation:data];
    } else if (data[@"function"]) {
        [self handleFunction:data];
    }
}

- (void)handleAnimation:(NSDictionary*)data
{
    AnimationBlockType block = data[@"animation"];
    if (block) {
        CAAnimation* animation = block();
        NSMutableDictionary* newData = [NSMutableDictionary dictionaryWithDictionary:data];
        [newData setObject:@YES forKey:@"isSequential"];
        [self doAnimation:animation data:newData];
    }
}

- (void)handleUnisonAnimation:(NSDictionary*)data
{
    CFTimeInterval duration;
    if (data[@"duration"]) {
        duration = [data[@"duration"] doubleValue];
    } else {
        duration = [self getLongestDuration:data[@"unison"]];
    }
    CFTimeInterval delay = [data[@"delay"] doubleValue];
    
    NSMutableDictionary* newData = [NSMutableDictionary dictionaryWithDictionary:data];
    [newData setObject:@(duration) forKey:@"duration"];
    [newData setObject:@(delay) forKey:@"delay"];
    [newData setObject:@YES forKey:@"isSequential"];
    
    CAAnimation* animation = [self emptyAnimation];
    [animation setDelegate:self];
    [self doAnimation:animation data:newData];
    
    [self handleUnisonAnimationList:data[@"unison"] parentDelay:delay];
}

- (void)handleUnisonAnimationList:(NSArray*)animations parentDelay:(CFTimeInterval)parentDelay
{
    for (NSUInteger i = 0, count = animations.count; i < count; i++) {
        NSDictionary* data = animations[i];
        AnimationBlockType block = data[@"animation"];
        if (block) {
            CAAnimation* animation = block();
            NSMutableDictionary* newData = [NSMutableDictionary dictionaryWithDictionary:data];
            CFTimeInterval delay = [data[@"delay"] doubleValue];
            [newData setObject:@(delay + parentDelay) forKey:@"delay"];
            [self doAnimation:animation data:newData];
        }
    }
}

- (void)handleFunction:(NSDictionary*)data
{
    NSMutableDictionary* newData = [NSMutableDictionary dictionaryWithDictionary:data];
    [newData setObject:@YES forKey:@"isSequential"];
    CAAnimation* animation = [self emptyAnimation];
    [animation setDelegate:self];
    [self doAnimation:animation data:newData];
}

- (CFTimeInterval)getLongestDuration:(NSArray*)animations
{
    CFTimeInterval longest = 0;
    for (NSUInteger i = 0, count = animations.count; i < count; i++) {
        NSDictionary* unisonData = animations[i];
        CFTimeInterval del = [unisonData[@"delay"] doubleValue];
        CFTimeInterval dur = [unisonData[@"duration"] doubleValue];
        if (del + dur > longest) {
            longest = del + dur;
        }
    }
    return longest;
}

- (CAAnimation *)emptyAnimation
{
    CAAnimation* animation = [CAAnimation animation];
    [self setAnimationDefaults:self.mainLayer animation:animation];
    return animation;
}

- (void)doAnimation:(CAAnimation*)animation data:(NSDictionary*)data
{
    NSString* name = [self uniqueName:data];
    CALayer *layer = [animation valueForKey:nil];
    CFTimeInterval delay = [data[@"delay"] doubleValue];
    CFTimeInterval duration = [data[@"duration"] doubleValue];
    CFTimeInterval now = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    animation.duration = duration;
    animation.beginTime = now + delay;
    [animation setValue:name forKey:@"name"];
    _runningAnimations[name] = @{
                                 @"animation":animation,
                                 @"data":data
                                 };
    [layer addAnimation:animation forKey:name];
}

- (NSString *)uniqueName:(NSDictionary*)data
{
    NSString* name = data[@"name"];
    if (!name) {
        name = [NSString stringWithFormat:@"%d", arc4random()];
    }
    return name;
}

- (void)setAnimationDefaults:(CALayer*)layer
                   animation:(id)animation
{
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    [animation setValue:layer forKey:nil];
    [animation setDelegate:self];
}

- (CFTimeInterval)two
{
    return 4.0f/0.5 / self.tempo * 60;
}
- (CFTimeInterval)one
{
    return 4.0f/1 / self.tempo * 60;
}
- (CFTimeInterval)half
{
    return 4.0f/2 / self.tempo * 60;
}
- (CFTimeInterval)third
{
    return 4.0f/3 / self.tempo * 60;
}
- (CFTimeInterval)quarter
{
    return 4.0f/4 / self.tempo * 60;
}
- (CFTimeInterval)sixth
{
    return 4.0f/6 / self.tempo * 60;
}
- (CFTimeInterval)eighth
{
    return 4.0f/8 / self.tempo * 60;
}
- (CFTimeInterval)sixteenth
{
    return 4.0f/16 / self.tempo * 60;
}

@end
