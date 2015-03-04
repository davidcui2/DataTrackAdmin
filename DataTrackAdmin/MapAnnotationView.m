//
//  MapAnnotationView.m
//  IIBProject
//
//  Created by Zhihao Cui on 27/01/2015.
//  Copyright (c) 2015 Zhihao Cui. All rights reserved.
//

#import "MapAnnotationView.h"

@implementation MapAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Set the frame size to the appropriate values.
        CGRect  myFrame = self.frame;
        myFrame.size.width = 40;
        myFrame.size.height = 40;
        self.frame = myFrame;
        
        // The opaque property is YES by default. Setting it to
        // NO allows map content to show through any unrendered parts of your view.
        self.opaque = NO;
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView != nil)
    {
        [self.superview bringSubviewToFront:self];
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect rect = self.bounds;
    BOOL isInside = CGRectContainsPoint(rect, point);
    if(!isInside)
    {
        for (UIView *view in self.subviews)
        {
            isInside = CGRectContainsPoint(view.frame, point);
            if(isInside)
                break;
        }
    }
    return isInside;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    // Get the custom callout view.
//    NSView *calloutView = self.calloutViewController.view;
//    if (selected) {
//        NSRect annotationViewBounds = self.bounds;
//        NSRect calloutViewFrame = calloutView.frame;
//        // Center the callout view above and to the right of the annotation view.
//        calloutViewFrame.origin.x = -(NSWidth(calloutViewFrame) - NSWidth(annotationViewBounds)) * 0.5;
//        calloutViewFrame.origin.y = -NSHeight(calloutViewFrame) + 15.0;
//        calloutView.frame = calloutViewFrame;
//        
//        [self addSubview:calloutView];
//    } else {
//        [calloutView.animator removeFromSuperview];
//    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
