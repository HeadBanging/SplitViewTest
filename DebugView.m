//
//  DebugView.m
//  Splitter2
//

#import "DebugView.h"

@implementation DebugView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setConstraints {
    id superview = self.superview;

    NSRect superFrame = [superview frame];
    superFrame.origin.x = 0;
    superFrame.origin.y = 0;
    self.frame = superFrame;
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(self); //Add constraints for the view
    
    [superview addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [superview addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[self]|"
                                             options:0
                                             metrics:nil
                                               views:views]];

}

-(void)testViewWithValue:(int)number {
    NSRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.height = 40;
    frame.size.width = 100;
    NSTextField* textField = [[NSTextField alloc] initWithFrame:frame];
    [textField setStringValue:[NSString stringWithFormat:@"Number %d",number]];
    [textField setBezeled:NO];
    [textField setDrawsBackground:YES];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [self addSubview:textField];
    
    [self setNeedsDisplay:YES];
    
}

- (BOOL)dragEnabled {
    return NSAlternateKeyMask == ([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask);
}




@end
