//
//  CADFlowLayout.m
//  IndoorIOS
//
//  Created by 陈革非 on 14/12/13.
//  Copyright (c) 2014年 chinaairdome. All rights reserved.
//

#import "CADFlowLayout.h"

@implementation CADFlowLayout

- (void) prepareLayout {
    [super prepareLayout];
    
    int screen_width = [[UIScreen mainScreen] currentMode].size.width;
//    NSLog(@"screen width = %i",screen_width);
    
    CGFloat scale_screen = [UIScreen mainScreen].scale;
//    NSLog(@"screen scale = %f",scale_screen);
    
    self.minimumInteritemSpacing = 2;
    self.minimumLineSpacing = 2;
    self.itemSize = CGSizeMake((screen_width/scale_screen-6)/2, 44);
    self.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    
}

- (CGSize) collectionViewContentSize {
    CGSize size = [super collectionViewContentSize];
    
    return size;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
//    if(self.animator) {
//        return [self.animator itemsInRect:rect];
//    }
//    
//    self.animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    
    CGSize contentSize = [self collectionViewContentSize];
    CGRect size = (CGRect) { .size = contentSize };
    NSArray *items = [super layoutAttributesForElementsInRect:size];
    
//    [items enumerateObjectsUsingBlock:^(id<UIDynamicItem> obj, NSUInteger idx, BOOL *stop) {
//        UIAttachmentBehavior *behavior = [[UIAttachmentBehavior alloc] initWithItem:obj
//                                                                   attachedToAnchor:[obj center]];
//        
//        behavior.length = 0.0f;
//        behavior.damping = 0.2f;
//        behavior.frequency = 1.0f;
//        
//        [self.animator addBehavior:behavior];
//    }];
    
    return items;
}

//-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [self.animator layoutAttributesForCellAtIndexPath:indexPath];
//}

//-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
//    UIScrollView *scrollView = self.collectionView;
//    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
//    
//    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
//    
//    [self.animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehavior, NSUInteger idx, BOOL *stop) {
//        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehavior.anchorPoint.y);
//        CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehavior.anchorPoint.x);
//        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
//        
//        UICollectionViewLayoutAttributes *item = springBehavior.items.firstObject;
//        CGPoint center = item.center;
//        if (delta < 0) {
//            center.y += MAX(delta, delta*scrollResistance);
//        }
//        else {
//            center.y += MIN(delta, delta*scrollResistance);
//        }
//        item.center = center;
//        
//        [self.animator updateItemUsingCurrentState:item];
//    }];
//    
//    return NO;
//}

@end
