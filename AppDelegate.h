//
//  AppDelegate.h
//  Splitter2
//

#import <Cocoa/Cocoa.h>
#import "ViewForSplitter.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    int counter;
}

- (int)getViewCounter;
- (int)currentViewCounter;
- (void)decrementViewCounter;

@end

