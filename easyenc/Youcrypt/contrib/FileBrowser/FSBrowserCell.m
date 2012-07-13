/*
 Copyright (c) 2011, Stefan Reitshamer http://www.haystacksoftware.com
 
 All rights reserved.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "FSBrowserCell.h"

#define CHECKBOX_WIDTH 5

@implementation FSBrowserCell

- (id)init {
    self = [super init];
    [self setLineBreakMode:NSLineBreakByTruncatingTail];
    [self setButtonType:NSSwitchButton];
    [self setAllowsMixedState:NO];
    [self acceptsFirstResponder];

    return self;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
    NSLog(@"HIT TEST");
    NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
    NSRect checkboxRect = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, CHECKBOX_WIDTH, cellFrame.size.height);
    if (NSMouseInRect(point, checkboxRect, [controlView isFlipped])) {
        return NSCellHitTrackableArea;    
    }
    return [super hitTestForEvent:event inRect:cellFrame ofView:controlView];    
}
 
@end
