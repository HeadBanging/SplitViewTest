//
//  DebugView.h
//  Splitter2
//

#import <Cocoa/Cocoa.h>

@interface DebugView : NSView

-(void)setConstraints;
-(void)testViewWithValue:(int)number;

- (BOOL)dragEnabled;

@end
