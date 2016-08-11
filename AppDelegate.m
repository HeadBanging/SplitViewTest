//
//  AppDelegate.m
//  Splitter2
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    counter = 0;
    [ViewForSplitter addSplitViewIsVertical:NO inView:_window.contentView];// isBase:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (int)getViewCounter {
    int returnValue = counter;
    counter++;
    return returnValue;
}

- (int)currentViewCounter {return counter;}

- (void)decrementViewCounter {counter--;}

@end
