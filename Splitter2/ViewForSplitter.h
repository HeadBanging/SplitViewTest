//
//  ViewForSplitter.h
//  Splitter2
//

#import <Cocoa/Cocoa.h>
#import "DebugView.h"

@interface ViewForSplitter : NSView <NSDraggingSource> {
    NSPoint fHitPoint;
    NSRect fFrameWhenHit;
    BOOL dragging;
    BOOL isHighlighted;
    
    NSView* fHitView;
}
@property (assign, setter=setHighlighted:) BOOL isHighlighted;

+ (void)addSplitViewIsVertical:(bool)isVertical inView:(NSView*)view;// isBase:(BOOL)base;

- (IBAction)splitHorizontally:(id)sender;



@end
