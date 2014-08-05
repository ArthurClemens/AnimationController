
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.animationController = [[MyAnimationController alloc] initWithView:self.view];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.animationController restart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.animationController cleanup];
}

@end
