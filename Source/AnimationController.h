// AnimationController.h
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

#import <Foundation/Foundation.h>
#include <stdlib.h>

/**
Block signatures
*/
typedef CAAnimation* (^AnimationBlockType)(void);
typedef void (^FunctionBlockType)(void);
typedef BOOL (^ConditionalBlockType)(void);
typedef void (^StartBlockType)(void);
typedef void (^CompletionBlockType)(void);
typedef void (^BeforeAnimationBlockType)(void);

/**
 Tap behavior options. More than one can be set.
 */
typedef enum {
    ACNone            = 0,
    ACRestartAtEnd    = 1 << 0/*,
    ACPauseAndPlay    = 1 << 1*/
} ClickBehavior;

/**
AnimationController is a class to create a sequence of Core Animations in code, allowing you to keep better control of timings and effects and ultimately, to create more sophisticated animations.
*/

@interface AnimationController : NSObject

// VIEWS

@property(nonatomic, retain) UIView* view;

/**
 The base layer to draw on. Default: view.layer, but can be any layer if added to self.view.layer.
 */
@property(nonatomic, retain) CALayer* layer;

// DATA

/**
    Array of objects of type NSDictionary.
 */
@property(nonatomic, retain) NSArray* actions;

// STATUS

/**
 What needs to happen on tap. Uses ClickBehavior values.
 */
@property(atomic) int tapBehavior;

/**
 The paused state of the running animation. Not implemented.
 */
@property(atomic) BOOL paused;

/**
 The completed state of the running animation.
 */
@property(atomic) BOOL completed;

/**
 The number of times the animation has played.
 */
@property(atomic) unsigned int count;

// TIMING

/**
 Base speed (convenience property; tempo is only used with other predefined time units).
 */
@property(atomic) CFTimeInterval tempo;
@property(atomic, readonly) CFTimeInterval two;
@property(atomic, readonly) CFTimeInterval one;
@property(atomic, readonly) CFTimeInterval half;
@property(atomic, readonly) CFTimeInterval third;
@property(atomic, readonly) CFTimeInterval quarter;
@property(atomic, readonly) CFTimeInterval sixth;
@property(atomic, readonly) CFTimeInterval eighth;
@property(atomic, readonly) CFTimeInterval sixteenth;

@property(nonatomic, copy) CompletionBlockType completionHandler;

- (id)initWithView:(UIView *)UIView;
- (void)cleanup;
- (void)prepare;
- (void)start;
- (void)restart;
- (void)next;
- (void)setAnimationDefaults:(CALayer*)layer
                   animation:(id)animation;
- (void)setStartBlock:(StartBlockType)block
            animation:(CAAnimation*)animation;
- (void)setCompletionBlock:(CompletionBlockType)block
                 animation:(CAAnimation*)animation;
- (void)setOnAnimationComplete:(CompletionBlockType)block;

@end

