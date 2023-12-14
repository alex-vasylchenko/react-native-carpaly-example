#import "RCTCarPlayNavigator.h"
#import "example-Swift.h"

@implementation RCTCarPlayNavigator

// To export a module named CarPlayNavigator
RCT_EXPORT_MODULE();

// redirect to another app in Car Play (in my case Apple/Google maps)
RCT_EXPORT_METHOD(redirect:(NSString *)link) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [CarSceneDelegate.sceneApplication openURL: [NSURL URLWithString:link] options:nil completionHandler:nil];
  });
}

@end
