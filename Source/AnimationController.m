// AnimationController.m
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

#import "AnimationController.h"
#import <QuartzCore/QuartzCore.h>

static const CFTimeInterval DEFAULT_TEMPO = 120.0f;

NSMutableDictionary* _actionStatus;
NSMutableArray* _workingActions;
NSMutableDictionary* _runningActions;
NSMutableDictionary* _repeatCounts;
int _workingActionIndex;
NSUInteger _unique_id = 0;

@implementation AnimationController

- (id)initWithView:(UIView *)UIView
{
    self = [super init];
    if (self) {
        self.view = UIView;
        self.tempo = DEFAULT_TEMPO;
        self.tapBehavior = ACNone;
        self.count = 0;
        self.layer = self.view.layer;
    }
    return self;
}

- (void)cleanup
{
    if (self.layer) {
        [self.layer removeAllAnimations];
        [self.layer removeFromSuperlayer];
    }
}

- (void)prepare
{
    [self.layer removeAllAnimations];
}

- (void)start
{
    [self setupTapBehavior];
    [self initActions];
    [self next];
}

- (void)restart
{
    [self prepare];
    [self initActions];
    [self next];
}

- (void)initActions
{
    self.paused = NO;
    self.completed = NO;
    _runningActions = [NSMutableDictionary new];
    _repeatCounts = [NSMutableDictionary new];
    _workingActions = [NSMutableArray arrayWithArray:self.actions];
    _workingActionIndex = 0;
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state != UIGestureRecognizerStateRecognized) return;
    if (self.completed) {
        if (self.tapBehavior & ACRestartAtEnd) {
            [self restart];
        }
    } else {
        /*
        if (self.tapBehavior & ACPauseAndPlay) {
            self.paused = !self.paused;
            if (self.paused) {
                [self pauseActions];
            } else {
                [self resumeActions];
            }
        }
         */
    }
}

- (void)pauseActions
{
    for (NSString* key in _runningActions) {
        CAAnimation* animation = _runningActions[key][@"animation"];
        CALayer *layer = [animation valueForKey:nil];
        CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
    }
}

- (void)resumeActions
{
    for (NSString* key in _runningActions) {
        CAAnimation* animation = _runningActions[key][@"animation"];
        CALayer *layer = [animation valueForKey:nil];
        CFTimeInterval pausedTime = [layer timeOffset];
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        layer.beginTime = timeSincePause;
    }
}

- (void)animationDidStart:(CAAnimation *)animation
{
    NSString* name = [animation valueForKey:@"name"];
    NSDictionary* action = _runningActions[name];
    [self handleStartBlock:action];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    NSString* name = [animation valueForKey:@"name"];
    [self animationDone:name];
}

/**
Pass a callback block:
 
[self setOnAnimationComplete:^(void){
    NSLog(@"done");
}];
*/
- (void)setOnAnimationComplete:(CompletionBlockType)block
{
    self.completionHandler = block;
}

- (void)animationDone:(NSString *)name
{
    NSDictionary* action = _runningActions[name];
    [self handleCompletionBlock:action];
    
    // By exception the action of type function is called right after the (dummy) animation
    // so that delay can be used as any other action
    
    if (action[@"action"][@"function"]) {
        FunctionBlockType block = action[@"action"][@"function"];
        block();
    }
    
    if (self.paused || self.completed) {
        return;
    }
    
    BOOL isSequential = [action[@"action"][@"isSequential"] boolValue];
    [_runningActions removeObjectForKey:name];
    
    if (_workingActionIndex == _workingActions.count) {
        [self finish];
    }
    if (isSequential) {
        [self next];
    }
}

- (void)next
{
    if (self.paused || self.completed) {
        return;
    }
    if (_workingActionIndex == _workingActions.count) {
        return;
    }
    NSDictionary* action = _workingActions[_workingActionIndex++];
    [self maybeHandleAction:action];
}

- (void)finish
{
    self.completed = true;
    self.count++;
    if (self.completionHandler) {
        self.completionHandler();
    }
}

- (void)maybeHandleAction:(NSDictionary*)action
{
    if (action[@"conditional"]) {
        BOOL result;
        if ([action[@"conditional"] isKindOfClass:NSClassFromString(@"NSValue")]) {
            result = [action[@"conditional"] boolValue];
        } else {
            // assume block
            ConditionalBlockType block = action[@"conditional"];
            result = block();
        }
        if (result) {
            [self handleAction:action];
        } else {
            [self next];
        }
    } else {
        [self handleAction:action];
    }
}

- (void)handleAction:(NSDictionary*)action
{
    if (action[@"jump"]) {
        [self handleJump:action];
    } else if (action[@"unison"]) {
        [self handleUnisonAnimation:action];
    } else if (action[@"animation"]) {
        [self handleAnimation:action];
    } else if (action[@"function"]) {
        [self handleFunction:action];
    }
}

- (void)handleAnimation:(NSDictionary*)action
{
    CAAnimation* animation = [self animationFromAction:action];
    if (animation) {
        NSMutableDictionary* newAction = [NSMutableDictionary dictionaryWithDictionary:action];
        [newAction setObject:@YES forKey:@"isSequential"];
        [self doAnimation:animation action:newAction];
    } else {
        [self next];
    }
}

- (CAAnimation*)animationFromAction:(NSDictionary*)action
{
    CAAnimation* animation;
    if ([action[@"animation"] isKindOfClass:NSClassFromString(@"CAAnimation")]) {
        animation = action[@"animation"];
    } else {
        // assume block
        AnimationBlockType block = action[@"animation"];
        if (block) {
            animation = block();
        }
    }
    return animation;
}

- (void)doAnimation:(CAAnimation*)animation action:(NSDictionary*)action
{
    NSString* name = [self uniqueName:action];
    CALayer *layer = [animation valueForKey:nil];
    CFTimeInterval delay = [action[@"delay"] doubleValue];
    CFTimeInterval duration = [action[@"duration"] doubleValue];
    CFTimeInterval now = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    animation.duration = duration;
    animation.beginTime = now + delay;
    [animation setValue:name forKey:@"name"];
    _runningActions[name] = @{
                                 @"animation":animation,
                                 @"action":action
                                };
    [layer addAnimation:animation forKey:name];
}

- (void)handleUnisonAnimation:(NSDictionary*)action
{
    CFTimeInterval duration;
    if (action[@"duration"]) {
        duration = [action[@"duration"] doubleValue];
    } else {
        duration = [self getLongestDuration:action[@"unison"]];
    }
    CFTimeInterval delay = [action[@"delay"] doubleValue];
    
    NSMutableDictionary* newAction = [NSMutableDictionary dictionaryWithDictionary:action];
    [newAction setObject:@(duration) forKey:@"duration"];
    [newAction setObject:@(delay) forKey:@"delay"];
    [newAction setObject:@YES forKey:@"isSequential"];
    
    CAAnimation* animation = [self emptyAnimation];
    [animation setDelegate:self];
    [self doAnimation:animation action:newAction];
    
    [self handleUnisonAnimationList:action[@"unison"] parentDelay:delay];
}

- (void)handleUnisonAnimationList:(NSArray*)actions parentDelay:(CFTimeInterval)parentDelay
{
    for (NSUInteger i = 0, count = actions.count; i < count; i++) {
        NSDictionary* action = actions[i];
        NSMutableDictionary* newAction = [NSMutableDictionary dictionaryWithDictionary:action];
        CFTimeInterval delay = [action[@"delay"] doubleValue];
        [newAction setObject:@(delay + parentDelay) forKey:@"delay"];
        CAAnimation* animation = [self animationFromAction:action];
        if (animation) {
            [self doAnimation:animation action:newAction];
        } else {
            [self maybeHandleAction:newAction];
        }
    }
}

- (void)handleJump:(NSDictionary*)action
{
    NSString* jumpName = action[@"jump"];
    NSString* name = action[@"name"];
    if (!name) {
        name = [NSString stringWithFormat:@"%d", _workingActionIndex];
    }
    
    int index = [self findIndexByName:jumpName];
    BOOL mayJump = NO;
    
    if (index != -1) {
        if (action[@"repeat"]) {
            int maxRepeat = [action[@"repeat"] intValue];
            int currentRepeat;
            if (_repeatCounts[name] == nil) {
                currentRepeat = 0;
                _repeatCounts[name] = [NSNumber numberWithInt:currentRepeat];
            } else {
                currentRepeat = [_repeatCounts[name] intValue];
            }
            if (currentRepeat < maxRepeat) {
                _repeatCounts[name] = [NSNumber numberWithInt:++currentRepeat];
                mayJump = YES;
            }
        } else {
            mayJump = YES;
        }
    }
    if (mayJump) {
        _workingActionIndex = index;
    }
    [self next];
}

- (void)handleFunction:(NSDictionary*)action
{
    NSMutableDictionary* newAction = [NSMutableDictionary dictionaryWithDictionary:action];
    [newAction setObject:@YES forKey:@"isSequential"];
    CAAnimation* animation = [self emptyAnimation];
    [animation setDelegate:self];
    [self doAnimation:animation action:newAction];
}

- (CFTimeInterval)getLongestDuration:(NSArray*)actions
{
    CFTimeInterval longest = 0;
    for (NSUInteger i = 0, count = actions.count; i < count; i++) {
        NSDictionary* unisonData = actions[i];
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
    [self setAnimationDefaults:self.layer animation:animation];
    return animation;
}

- (NSString *)uniqueName:(NSDictionary*)action
{
    NSString* name = action[@"name"];
    if (!name) {
        unsigned long uid = (unsigned long)[self createUid];
        name = [NSString stringWithFormat:@"%ld", uid];
    }
    return name;
}

/*
Sets a number of default animation properties.
*/
- (void)setAnimationDefaults:(CALayer*)layer
                   animation:(id)animation
{
    [animation setRepeatCount:1.0];
    [animation setRemovedOnCompletion:NO];
    [animation setFillMode:kCAFillModeForwards];
    [animation setValue:layer forKey:nil];
    [animation setDelegate:self];
}

/*
 Call with:
 
 StartBlockType block = ^(void) {
 ... do something
 };
 [self setStartBlock:block animation:animation];
 */
- (void)setStartBlock:(StartBlockType)block
            animation:(CAAnimation*)animation
{
    [animation setValue:block forKey:@"start"];
}

- (void)handleStartBlock:(NSDictionary*)action
{
    CAAnimation* animation = action[@"animation"];
    if ([animation valueForKey:@"start"]) {
        StartBlockType block = [animation valueForKey:@"start"];
        if (block) {
            block();
        }
    }
}

/*
Call with:

CompletionBlockType block = ^(void) {
    ... do something
};
[self setCompletionBlock:block animation:animation];
*/
- (void)setCompletionBlock:(CompletionBlockType)block
                 animation:(CAAnimation*)animation
{
    [animation setValue:block forKey:@"completion"];
}

- (void)handleCompletionBlock:(NSDictionary*)action
{
    CAAnimation* animation = action[@"animation"];
    if ([animation valueForKey:@"completion"]) {
        CompletionBlockType block = [animation valueForKey:@"completion"];
        if (block) {
            block();
        }
    }
}

- (NSUInteger)createUid
{
    if (_unique_id == NSUIntegerMax) {
        _unique_id = 0;
    }
    return _unique_id++;
}

- (int)findIndexByName:(NSString*)name
{
    for (NSUInteger i = 0, count = _workingActions.count; i < count; i++) {
        NSString* n = _workingActions[i][@"name"];
        if (name == n) {
            return (int)i;
        }
    }
    return -1;
}

- (void)setupTapBehavior
{
    if (self.tapBehavior != ACNone) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:singleTap];
    }
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
