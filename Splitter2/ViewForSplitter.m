//
//  ViewForSplitter.m
//  Splitter2
//

#import "ViewForSplitter.h"
#import "AppDelegate.h"

#import "DebugView.h"

@implementation ViewForSplitter

@dynamic isHighlighted;

#pragma mark Splitting

+ (void)addSplitViewIsVertical:(bool)isVertical inView:(NSView*)view {
    BOOL newView = YES;
    int newFrameCount = 1;
    
    id viewSplitter = view.superview;
    if ([[viewSplitter class] isSubclassOfClass:[NSSplitView class]] &&
        (((NSSplitView*)viewSplitter).vertical == isVertical)) {
        newView = NO;
    } else {
        if ([[viewSplitter class] isSubclassOfClass:[NSSplitView class]]) {
            newFrameCount = 2;
        }
        viewSplitter = [[NSSplitView alloc] initWithFrame:[view bounds]];
        [viewSplitter setVertical:isVertical];
        ((NSSplitView*)viewSplitter).dividerStyle = NSSplitViewDividerStylePaneSplitter;
    }
    
    int subviewCount = (int)[[viewSplitter subviews]count];
    NSSize superviewSize = view.frame.size;
    NSSize subviewSize;
    subviewSize.width = ((NSSplitView*)viewSplitter).vertical?superviewSize.width:superviewSize.width/subviewCount;
    subviewSize.height = ((NSSplitView*)viewSplitter).vertical?superviewSize.height/subviewCount:superviewSize.height;
    
    for (int i=0;i<newFrameCount;i++){
        ViewForSplitter* contentView = [ViewForSplitter new];
        
        NSRect frameForView = contentView.frame;
        frameForView.origin.x=0;
        frameForView.origin.y=0;
        id TestView = [[DebugView alloc] initWithFrame:frameForView];
        [contentView addSubview:TestView];
        [TestView setConstraints];
        
        [TestView testViewWithValue:[[NSApp delegate] getViewCounter]];
        
        NSRect contentFrame = contentView.frame;
        contentFrame.size = subviewSize;
        [contentView setFrame:contentFrame];
        [viewSplitter addSubview:contentView];
        [viewSplitter adjustSubviews];
        
        [contentView setNeedsDisplay:YES];
    }
    
    if (newView) {
        [viewSplitter setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [view addSubview:viewSplitter];
        [view setNeedsDisplay:YES];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(viewSplitter);
        [view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[viewSplitter]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewSplitter]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    if (isHighlighted) {
        [NSBezierPath setDefaultLineWidth:6.0];
        [[NSColor keyboardFocusIndicatorColor] set];
        [NSBezierPath strokeRect:self.bounds];
    }
}

- (id)initWithFrame:(CGRect)aRect {
    if ((self = [super initWithFrame:aRect])) {
        NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self registerForDraggedTypes:[NSArray arrayWithObjects: NSPasteboardTypeTIFF, nil]];
    }
    return self;
}

- (NSMenu*)contextualMenu {
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    
    NSMenuItem *addHorizontal = [[NSMenuItem alloc] initWithTitle:@"Horizontal Split" action:@selector(splitHorizontally:) keyEquivalent:@""];
    NSMenuItem *addVertical = [[NSMenuItem alloc] initWithTitle:@"Vertical Split" action:@selector(splitVertically:) keyEquivalent:@""];
    NSMenuItem *deleteSplit = [[NSMenuItem alloc] initWithTitle:@"Delete View" action:@selector(deleteView:) keyEquivalent:@""];
    
    [addHorizontal setEnabled:YES];
    [addVertical setEnabled:YES];
    [deleteSplit setEnabled:YES];
    [addHorizontal setTarget:self];
    [addVertical setTarget:self];
    [deleteSplit setTarget:self]; //shouldn't be enabled if the view being clicked on isn't root.
    [theMenu addItem:addHorizontal];
    [theMenu addItem:addVertical];
    [theMenu addItem:deleteSplit];

    [theMenu insertItem:[NSMenuItem separatorItem] atIndex:2];

    return theMenu;
}

- (void)rightMouseDown:(NSEvent*)theEvent {
    [[self contextualMenu] popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

- (IBAction)splitHorizontally:(id)sender {
    [ViewForSplitter addSplitViewIsVertical:NO inView:self];// isBase:NO];
}

- (IBAction)splitVertically:(id)sender {
    [ViewForSplitter addSplitViewIsVertical:YES inView:self];// isBase:NO];
}

- (IBAction)deleteView:(id)sender {
    NSLog(@"Debug %d",[[NSApp delegate] currentViewCounter]);
    if ([[NSApp delegate] currentViewCounter] == 1) {
        return; //mustn't delete the base view!
    }
    
    [self removeFromSuperview];
    [[NSApp delegate] decrementViewCounter];
}

#pragma mark Dragging

- (NSImage *)imageRepresentationOfView:(NSView*)draggingView {
    BOOL wasHidden = draggingView.isHidden;
    CGFloat wantedLayer = draggingView.wantsLayer;
    
    draggingView.hidden = NO;
    draggingView.wantsLayer = YES;
    
    NSImage *image = [[NSImage alloc] initWithSize:draggingView.bounds.size];
    [image lockFocus];
    CGContextRef ctx = [NSGraphicsContext currentContext].graphicsPort;
    [draggingView.layer renderInContext:ctx];
    [image unlockFocus];
    
    draggingView.wantsLayer = wantedLayer;
    draggingView.hidden = wasHidden;
    
    return image;
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSSize dragOffset = NSMakeSize(0.0, 0.0);
    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:[NSArray arrayWithObject:NSTIFFPboardType]  owner:self];
    
    DebugView *hitView;
    NSPoint startLocation = NSMakePoint(0, 0);
    NSImage *draggedImage;
    BOOL found = NO;
    
    fHitView = nil;
    while ((hitView = [[[self subviews] objectEnumerator] nextObject]) && !found) {

        if ([hitView isKindOfClass:[DebugView class]] && [(DebugView *)hitView dragEnabled]) {
            draggedImage = [self imageRepresentationOfView:hitView];
            startLocation = hitView.frame.origin;
            found = YES;
        }
    }
    if (draggedImage != nil) {
        [pboard setData:[draggedImage TIFFRepresentation] forType:NSTIFFPboardType];
        
        [self dragImage:draggedImage at:startLocation offset:dragOffset
                  event:theEvent pasteboard:pboard source:self slideBack:YES];
    }
    return;

}

- (void)setHighlighted:(BOOL)value {
    isHighlighted = value;
    [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        
        NSArray *paths = [pboard propertyListForType:NSFilenamesPboardType];
        for (NSString *path in paths) {
            NSError *error = nil;
            NSString *utiType = [[NSWorkspace sharedWorkspace]
                                 typeOfFile:path error:&error];
            if (![[NSWorkspace sharedWorkspace]
                  type:utiType conformsToType:(id)kUTTypeFolder]) {
                
                [self setHighlighted:NO];
                return NSDragOperationNone;
            }
        }
    }
    [self setHighlighted:YES];
    return NSDragOperationEvery;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    [self setHighlighted:NO];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender  {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    [self setHighlighted:NO];
    
    DebugView *hitView;
    BOOL found = NO;
    
    fHitView = nil;
    while ((hitView = [[[self subviews] objectEnumerator] nextObject]) && !found) {
        if ([hitView isKindOfClass:[DebugView class]] && [(DebugView *)hitView dragEnabled]) {
            found = YES;
        }
    }
    NSView* tempView = [sender draggingSource];
    [[[sender draggingSource] superview] replaceSubview:[sender draggingSource] with:hitView];
    
    [self replaceSubview:hitView with:tempView];
    [self setNeedsDisplay:YES];
    [[[sender draggingSource] superview] setNeedsDisplay:YES];
    return YES;
}

- (BOOL)isHighlighted {
    return isHighlighted;
}

@end
