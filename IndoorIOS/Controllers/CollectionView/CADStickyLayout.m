//
//  CADStickyLayout.m
//  IndoorIOS
//
//  Created by 陈革非 on 15/5/5.
//  Copyright (c) 2015年 chinaairdome. All rights reserved.
//

#import "CADStickyLayout.h"

//#define NUMBEROFCOLUMNS 8
#define SPACING 1

@interface CADStickyLayout ()

@end

@implementation CADStickyLayout

- (void)prepareLayout
{
    // for header
    if ([self.collectionView numberOfSections] <= 1) {
        return;
    }
    
    // for left side
    if ([self.collectionView numberOfItemsInSection:0] <= 1) {
        return;
    }
    
    NSUInteger column = 0; // Current column inside row
    CGFloat xOffset = 0.0;
    CGFloat yOffset = 0.0;
    CGFloat contentWidth = 0.0; // To determine the contentSize
    CGFloat contentHeight = 0.0; // To determine the contentSize
    
    if (self.itemAttributes.count > 0) { // We don't enter in this if statement the first time, we enter the following times
        for (int section = 0; section < [self.collectionView numberOfSections]; section++) {
            NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
            for (NSUInteger index = 0; index < numberOfItems; index++) {
                if (section != 0 && index != 0) { // This is a content cell that shouldn't be sticked
                    continue;
                }
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:section]];
                if (section == 0) { // We stick the first row
                    CGRect frame = attributes.frame;
                    frame.origin.y = self.collectionView.contentOffset.y;
                    attributes.frame = frame;
                    
                }
                if (index == 0) { // We stick the first column
                    CGRect frame = attributes.frame;
                    frame.origin.x = self.collectionView.contentOffset.x;
                    attributes.frame = frame;
                }
            }
        }
        
        return;
    }
    
    // The following code is only executed the first time we prepare the layout
    self.itemAttributes = [@[] mutableCopy];
    self.itemsSizeInSections = [[NSMutableDictionary alloc] init];
    
    // 获取header中的item个数，因为他是固定的。用它作为参照物，计算stepSize
    NSInteger numberOfItemsInHeader = [self.collectionView numberOfItemsInSection:0];
    
    // We loop through all items
    for (int section = 0; section < [self.collectionView numberOfSections]; section++) {
        NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemsSize = [self.itemsSizeInSections objectForKey:[[NSString alloc] initWithFormat:@"%i",section ]];
        if (!itemsSize || itemsSize.count != numberOfItems) {
            NSInteger stepSize = 1;
            stepSize = (numberOfItemsInHeader-1)/(numberOfItems-1);
            [self calculateItemsSizeAtSection:section withStepSize:stepSize];
        }
        
        NSMutableArray *sectionAttributes = [@[] mutableCopy];
        for (NSUInteger index = 0; index < numberOfItems; index++) {
            itemsSize = [self.itemsSizeInSections objectForKey:[[NSString alloc] initWithFormat:@"%i",section ]];
            CGSize itemSize = [itemsSize[index] CGSizeValue];
            
            // We create the UICollectionViewLayoutAttributes object for each item and add it to our array.
            // We will use this later in layoutAttributesForItemAtIndexPath:
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//            attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width - SPACING, itemSize.height - SPACING));
            if (section == 0) {
                attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width, itemSize.height));
            } else {
                attributes.frame = CGRectIntegral(CGRectMake(xOffset, yOffset, itemSize.width - SPACING - SPACING, itemSize.height - SPACING));
            }
            
            if (section == 0 && index == 0) {
                attributes.zIndex = 1024; // Set this value for the first item (Sec0Row0) in order to make it visible over first column and first row
            } else if (section == 0 || index == 0) {
                attributes.zIndex = 1023; // Set this value for the first row or section in order to set visible over the rest of the items
            }
            
            if (section == 0) {
                CGRect frame = attributes.frame;
                frame.origin.y = self.collectionView.contentOffset.y;
                attributes.frame = frame; // Stick to the top
            }
            if (index == 0) {
                CGRect frame = attributes.frame;
                frame.origin.x = self.collectionView.contentOffset.x;
                attributes.frame = frame; // Stick to the left
            }
            
            [sectionAttributes addObject:attributes];
            
            xOffset = xOffset+itemSize.width;
            column++;
            
            // Create a new row if this was the last column
            if (column == numberOfItems) {
                if (xOffset > contentWidth) {
                    contentWidth = xOffset;
                }
                
                // Reset values
                column = 0;
                xOffset = 0;
                yOffset += itemSize.height;
            }
        }
        [self.itemAttributes addObject:sectionAttributes];
    }
    
    // Get the last item to calculate the total height of the content
    UICollectionViewLayoutAttributes *attributes = [[self.itemAttributes lastObject] lastObject];
    contentHeight = attributes.frame.origin.y+attributes.frame.size.height;
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemAttributes[indexPath.section][indexPath.row];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [@[] mutableCopy];
    for (NSArray *section in self.itemAttributes) {
        [attributes addObjectsFromArray:[section filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
            return CGRectIntersectsRect(rect, [evaluatedObject frame]);
        }]]];
    }
    
    return attributes;
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES; // Set this to YES to call prepareLayout on every scroll
}

- (CGSize)sizeForItemWithColumnIndex:(NSUInteger)columnIndex withStepSize:(NSUInteger)stepSize
{
    NSString *text = @"-100元";
    /*
    switch (columnIndex) { // This only makes sense if the size of the items should be different
        case 0:
            text = @"Col 0";
            break;
        case 1:
            text = @"Col 1";
            break;
        case 2:
            text = @"Col 2";
            break;
        case 3:
            text = @"Col 3";
            break;
        case 4:
            text = @"Col 4";
            break;
        case 5:
            text = @"Col 5";
            break;
        case 6:
            text = @"Col 6";
            break;
        case 7:
            text = @"Col 7";
            break;
            
        default:
            break;
    }
     */
    CGSize size = [text sizeWithAttributes: @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:15]}];
    if (columnIndex == 0) {
        size.width += 16; // In our design the first column should be the widest one
        return CGSizeMake([@(size.width + 9) floatValue], 40);
    }
    float width = [@(size.width + 9) floatValue];
    width = width * stepSize;
    return CGSizeMake(width, 40); // Extra space of 9px for all the items
}

- (void)calculateItemsSizeAtSection:(NSInteger)section withStepSize:(NSInteger)stepSize
{
    NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    NSMutableArray *itemsSize = [self.itemsSizeInSections objectForKey:[[NSString alloc] initWithFormat:@"%td",section ]];
    if (!itemsSize) {
        itemsSize = [[NSMutableArray alloc] init];
        [self.itemsSizeInSections setObject:itemsSize forKey:[[NSString alloc] initWithFormat:@"%td",section ]];
    }
    for (NSUInteger index = 0; index < numberOfItems; index++) {
        if (itemsSize.count <= index) {
            CGSize itemSize = [self sizeForItemWithColumnIndex:index withStepSize:stepSize];
            NSValue *itemSizeValue = [NSValue valueWithCGSize:itemSize];
            [itemsSize addObject:itemSizeValue];
        }
    }
}

@end
