# Core Animation Controller for iOS and Cocoa

AnimationController is a Cocoa class to create a sequence of Core Animations in code, allowing you to keep better control of timings and effects and ultimately, to create more sophisticated animations.


## Main features

1. Animations are automatically played one after the other.
1. Animations can be grouped to play simultaneously - animating different layers if desired.
1. Conditionals check if an animation should be played or skipped.
1. Regular method calls can be inserted in between animations.
1. Jump to an action to create a loop; set a maximum number of repeats.
1. Use regular CAAnimation objects.
1. Script-like syntax thanks to [Objective-C Literals](http://clang.llvm.org/docs/ObjectiveCLiterals.html) and blocks. Conventional code is possible too.


## Demos

The repository contains 4 demo projects, from simple to more complex:

1. "AnimationControllerDemo-HelloWorld" shows the most basic AnimationController subclass
1. "AnimationControllerDemo-KitchenSink" shows most of the features
1. "AnimationControllerDemo-Group" demonstrates animating a group of layers
1. "AnimationControllerDemo-Disney" is a more elaborate animation inspired by ["Squash & Stretch"](http://the12principles.tumblr.com/post/84179300674/squash-stretch) ("12 Principles of Animation").

### Demo videos

1. [KitchenSink](https://youtu.be/0nmAO0puU70)
1. [Group](http://youtu.be/Fe7lxMJTgZ4)
1. [Disney](http://youtu.be/tjW6ka2ytCY)

## Background

Creating a chain of Core Animations in Cocoa is hard. Cocoa does offer a way to register for the "completed" message with ``animationDidStop:``, but managing more than two animations will quickly become a clutter of interleaved callbacks.

AnimationController hides this complexity by managing what needs to be played when, giving you more control over the animations.

Also, animation code can be better structured by separating concerns:

1. The layer's **visual manifestation** (shape, image, text, etcetera - but no transform properties).
1. The layer's initial **transform properties** (position, scale, etcetera).
1. The **animation properties** (type, position, scale, etcetera - except timings)
1. The **animation timings** (order, duration, delay, repeats).

By separating manifestation, transforms and timing, it becomes easier:

* To address the same layer from multiple spots (creation of animation, preparing running the animation).
* To prepare layers for animation, and to reuse this preparation when replaying or restarting (for instance when the app gets in the foreground).
* To keep all timing settings tidy and in one place.

AnimationController does not enforce this methodology - you are free to do it this way, or another way. Have a look at the demo code to see how this may benefit you.


## Musical rhythm

In [Animation Timing on iOS - Defining time with music notation](https://medium.com/@iamandybarnard/animation-timing-on-ios-910e6a58098b), Andy Barnard makes a case for using a set of time constants from one base unit:

> [In musical notation] the base unit translates as the beats per minute (BPM) and all subsequent time values (minim, crotchet, quaver…) derive from this. By building upon a common foundation in this way, we gain a large amount of both control and flexibility over our animations.

By using this, 

> synchronising and chaining multiple animations to build complex sequences becomes an intuitive exercise due to the ease at which durations and start times can easily be coordinated across animations.

AnimationController provides a couple of convenience properties to use musical rhythm:

* ``tempo``: the number of beats per minute (in musical notation each beat is one quarter note). For the default tempo of 120, there are 120 quarter notes per minute.
* durations:``two`` ``one`` ``half`` ``third`` ``quarter`` ``sixth`` ``eighth`` ``sixteenth``

In the action properties (see below), it is used like this:

    @"duration" : @(self.quarter)
    @"duration" : @(self.one - self.eighth)
    @"duration" : @(self.two * 2)

Again, AnimationController does not enforce to use this. You can define your own time units, or use absolute timings.


## Setting up an animation

An "animation" is the complete chain of core animations from start to end. In AnimationController terminology: an animation is built from a list of actions. Each action will contain a CAAnimation.

The animation is managed by a subclass of AnimationController.

### AnimationController subclass

In your subclass header, include AnimationController and (optionally but conveniently) the ``AnimationController+ShorthandAdditions`` category:

    #import "AnimationController.h"
    #import "AnimationController+ShorthandAdditions.h"

    @interface MyAnimationController : AnimationController
    @end

Your implementation file will contain:

    - (id)initWithView:(UIView *)UIView
    {
        self = [super initWithView:UIView];
        
        // setup code, for instance:
        self.tempo = 120;
        [self create]; // create layers
        [self prepare]; // prepare layers for animation
        self.actions = [self actions]; // create animation actions
        [self start]; // start animation
        
        return self;
    }

#### create

Create layers (shapes, images, texts - without position and timing attributes) and add them to the AnimationController layer. This is by default the view's layer (see HelloWorld):

    myLayer = [self createLayer];
    [self.layer addSublayer:myLayer];

Alternatively create a separate layer to draw animations on (see demo "Group"):

    self.layer = [self backgroundLayer]; // re-assigns the default view.layer
    // more sub layers
    [self.view.layer addSublayer:self.layer];

#### prepare

Set layers to their start state (position, opacity, etcetera), so that the animation can be started and replayed from here.

For instance:

    - (void)prepare
    {
        [super prepare];
        [myLayer removeAllAnimations];
        [self centerLayer:myLayer toLayer:self.layer];
        myLayer.opacity = 0.0;
    }

#### create actions

Pass a list of actions. An action is an NSDictionary with properties "animation", "delay" and "duration" that describe how the animation should be performed. See below for the [full list of action properties](#action-properties).

    @{
        @"animation": [self fadeIn],
        @"delay": @(self.one),
        @"duration" : @(self.one)
    }

Property "animation" contains a block that returns an (``CAAnimation``) object. Instead of the call ``[self fadeIn]`` the animation creation code could be placed here, but the list will be cleaner and shorter by having the creation code separated from the list.

#### About creating animations

The animations should not contain ``duration`` or ``beginTime`` properties - these will be set in the actions.

The ``AnimationController+ShorthandAdditions`` category contains a number of convenience methods to create animations. Check the demos for examples.

If you create your own animations, always call ``setAnimationDefaults`` - this will set the layer and delegate.

#### start

Speaks for itself.

### Creating an instance

For instance in your ViewController's ``viewDidLoad``, instantiate and pass the controller's view:

    - (void)viewDidLoad
    {
        [super viewDidLoad];
        self.animationController = [[MyAnimationController alloc] initWithView:self.view];
    }


## AnimationController properties

* ``tapBehavior``: What needs to happen on tap. Set to ``ACRestartAtEnd`` to replay the animation once completed.
* ``completed`` : The completed state of the running animation.
* ``count``: The number of times the animation has completed.

See also [Musical rhythm](#musical-rhythm) properties.

## Action properties

An animation is defined by a list of actions. Each action is a NSDictionary that contains animation properties.

3 Types of action are defined: animation, unison and function.

### Action type: animation

The value for key "animation" is a CAAnimation. Either use block notation or return a CAAnimation directly.

The difference is that blocks will be evaluated only when the action is triggered, while returning a CAAnimation directly will add the CAAnimation object to the action list.

#### Block notation

    @{
        @"animation": ^(void) {
            return [self fadeIn];
        }
    }

Block that returns a ``CAAnimation`` (or subclass). Block should be of type ``AnimationBlockType`` (accepts ``void``, returns ``CAAnimation*``).

#### Returning a CAAnimation

    @{
        @"animation": [self fadeIn]
    }
    
or: 

    @{
        @"animation": [self opacityAnimation:myLayer
                                        from:0.0
                                          to:1.0
                              timingFunction:[self easeIn]]
    }


### Action type: unison

    @{
        @"unison": @[
            @{
                @"animation": ^(void) {
                    return [self shrink];
                }
            },
            @{
                @"animation": ^(void) {
                    return [self moveToSide];
                }
            }
        ]
    }
        
Array of actions that will be started simultaneously. This is different from a ``CAAnimationGroup`` that applies multiple animations to the same layer. The unison can play **different layers simulaneously**.

Relative timings can be controlled with delay and duration.

``delay`` and ``duration`` can be passed to the unison action itself:

* If the duration is shorter than the longest item in the list, the item will not be clipped (unlike ``CAAnimationGroup``); if the next action uses the same layer, unexpected results may happen. Unlike you want the animation to last longer, the best approach is often to not set the duration.
* If no duration is set, the duration is derived from the longest delay+duration combination in the unison list of actions.

### Action type: function

    @{
        @"function": ^(void) {
            [self resetLayers];
        }
    }

Block that calls a method. Block should be of type ``FunctionBlockType`` (accepts ``void``, returns ``void``).

``delay`` and ``duration`` can be passed to a function action, otherwise no duration is assumed.


### duration

    @{
        @"animation": ...,
        @"duration" : @(self.one)
    }

Animation duraton in seconds, type ``NSNumber``. Alternatively use predefined musical notation: ``@(self.quarter)``, see [Musical rhythm](#musical-rhythm).

With an unison action: if no duration is passed, the duration is derived from the longest delay+duration combination in the unison list of actions.

### delay

    @{
        @"animation": ...,
        @"delay" : @(self.one)
    }
    
Animation delay in seconds, type ``NSNumber``. Alternatively use predefined musical notation: ``@(self.quarter)``, see [Musical rhythm](#musical-rhythm).

### conditional

Conditionally performs an action, dependent on the result of the block.

The same as with "animation", blocks will be evaluated when the action is triggered, so this will often be preferred to directly returning a BOOL value.

#### Block notation

    @{
        @"conditional": ^(void) {
            return self.count > 0;
        },
        @"animation": ^(void) {
            return [self hideRepeatButton];
        }
    }

Conditional blocks should be of type ``ConditionalBlockType`` (accepts ``void``, returns ``BOOL``).

#### Returning a BOOL as NSValue

    @{
        @"conditional": @(self.count > 0),
        @"animation": ^(void) {
            return [self hideRepeatButton];
        }
    }

### name

    @{
        @"name": @"move-around",
        ...
    }
    
Actions can optionally be named. This is only required for ``jump``. If no name is given, actions are auto named. Type ``NSString``.
    
### jump

    @{
        @"name": @"move-around",
        ...
    },
    @{
        @"jump": @"move-around"
    }

Jump to a named action, type ``NSString``. This can only be used with actions of type "animation" (not inside a group of unison actions).

### repeat

    @{
        @"name": @"move-around",
        ...
    },
    @{
        @"jump": @"move-around",
        @"repeat": @3
    }
    
Repeat jump a maximum of n times. If not set, the jump will be repeated indefinitely.



