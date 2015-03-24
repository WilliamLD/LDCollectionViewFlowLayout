//
//  LDCollectionViewFlowLayout.m
//  FGoBK
//
//  Created by LD on 15-3-9.
//  Copyright (c) 2015年 baojun. All rights reserved.
//

#import "LDCollectionViewFlowLayout.h"


@interface LayoutElement : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) NSInteger column; // 0 : left;  1 : right;
@property (nonatomic, copy)   NSIndexPath *indexPath;

@end

@implementation LayoutElement

-(instancetype)init
{
    self = [super init];
    
    if(self){
        self.frame = CGRectZero;
        self.column = 0;
    }
    
    return self;
}


@end

// ********************************************************************************************

@interface LDCollectionViewFlowLayout ()

@property (nonatomic, strong) NSDictionary  *framesForHeader;
@property (nonatomic, strong) NSDictionary  *framesForFooter;

@property (nonatomic, strong) NSDictionary  *framesForItem;

@property (nonatomic, strong) NSMutableDictionary *attributesForIndexPath;

@property (nonatomic, assign) CGSize contentSize;

@end


@implementation LDCollectionViewFlowLayout


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.attributesForIndexPath = [NSMutableDictionary new];
    }
    return self;
}


- (void)prepareLayout
{
    NSMutableDictionary *framesForHeader = [NSMutableDictionary dictionary];
    NSMutableDictionary *framesForFooter = [NSMutableDictionary dictionary];
    NSMutableDictionary *framesForItem = [NSMutableDictionary dictionary];
    
    
    NSInteger sections = [self.collectionView numberOfSections];
    
    UIEdgeInsets sectionEdgeInsets = self.sectionInset;
    CGFloat interitemSpacing       = self.minimumInteritemSpacing;
    CGFloat lineSpacing            = self.minimumLineSpacing;
    
    CGFloat maxH = 0;
    
     // -----  记录具有最大y 和 第二大y 的element. 如果, 两者最大y值相等, 则左边的为第二大, 右边的为最大
    LayoutElement *elementWithMaxY = [LayoutElement new];
    elementWithMaxY.frame = CGRectZero;
    elementWithMaxY.column = 1;
    
    LayoutElement *elementWithSecondY = [LayoutElement new];
    elementWithSecondY.frame = CGRectZero;
    elementWithSecondY.column = 0;
    
    
    for (int section = 0; section < sections; section ++) {
        
        if([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)] && [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)])
        {
            sectionEdgeInsets = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }
        
        if([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)] && [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)])
        {
            interitemSpacing = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
        }
        
        if([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)] && [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)])
        {
            lineSpacing = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
        }
        
        
        
        // Header
        
        CGRect headerFrame;
        
        if([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)] &&
           [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)])
        {
            CGSize headerSize = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
            
            
            CGFloat x = -self.collectionView.contentInset.left;
            CGFloat y = maxH;
            CGFloat w = self.collectionView.bounds.size.width - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
            headerFrame = CGRectMake(x, y,  w, headerSize.height);
            
            
            framesForHeader[@(section)] = [NSValue valueWithCGRect:headerFrame];
            
            maxH += headerFrame.size.height;
        }
        maxH += sectionEdgeInsets.top;
        
        
        //------------ item

        for (int item = 0; item < [self.collectionView numberOfItemsInSection:section]; item ++) {
            
            CGSize itemSize = self.itemSize;
            
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:item inSection:section];

            if([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)] && [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
            {
                itemSize = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath: currentIndexPath];

            }
            
            
            LayoutElement *itemElement = [LayoutElement new];
            itemElement.indexPath = currentIndexPath;
            
            CGFloat minAvailableX = self.collectionView.contentInset.left + sectionEdgeInsets.left;
            
            if (item == 0) {
                itemElement.frame = CGRectMake(minAvailableX, maxH, itemSize.width, itemSize.height);
                
                itemElement.column = 0;
                
                elementWithMaxY = itemElement;
            }
            
            else if (item == 1) {
                
                if (itemSize.width + CGRectGetMaxX(elementWithMaxY.frame) + interitemSpacing + sectionEdgeInsets.right + self.collectionView.contentInset.right > self.collectionView.bounds.size.width) {
                    itemElement.frame = CGRectMake(minAvailableX, maxH + lineSpacing, itemSize.width, itemSize.height);
                    itemElement.column = 0;
                    
                } else {
                    itemElement.frame = CGRectMake(CGRectGetMaxX(elementWithMaxY.frame) + interitemSpacing, CGRectGetMinY(elementWithMaxY.frame), itemSize.width, itemSize.height);
                    itemElement.column = 1;
                }
                
            }
            
            
            else {
                
                if (itemSize.width + CGRectGetWidth(elementWithMaxY.frame) + interitemSpacing + sectionEdgeInsets.right + sectionEdgeInsets.left + self.collectionView.contentInset.right + self.collectionView.contentInset.left > self.collectionView.bounds.size.width) {
                    itemElement.frame = CGRectMake(minAvailableX, maxH + lineSpacing, itemSize.width, itemSize.height);
                    itemElement.column = 0;
                    
                } else {
                    
                    itemElement.frame = CGRectMake(CGRectGetMinX(elementWithSecondY.frame), CGRectGetMaxY(elementWithSecondY.frame) + lineSpacing, itemSize.width, itemSize.height);
                    itemElement.column = elementWithSecondY.column;
                    
                }
                
            }
            
            
            // -----  记录具有最大y 和 第二大y 的element. 如果, 两者最大y值相等, 则左边的为第二大, 右边的为最大
            if (CGRectGetMaxY(itemElement.frame) > CGRectGetMaxY(elementWithMaxY.frame)  || (CGRectGetMaxY(itemElement.frame) == CGRectGetMaxY(elementWithMaxY.frame) && itemElement.column == 1)) {
                
                elementWithSecondY = elementWithMaxY;
                
                elementWithMaxY = itemElement;
                
            } else {
                elementWithSecondY = itemElement;
            }
            
            maxH = CGRectGetMaxY(elementWithMaxY.frame);
            
            
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:currentIndexPath];
            
            attributes.frame = itemElement.frame;
            
            self.attributesForIndexPath[currentIndexPath] = attributes;
            
        }

        
        
        // footer
        
        maxH += sectionEdgeInsets.bottom;
        
        CGRect footerFrame;
        if([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)] && [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]){
            CGSize footerSize = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
            
            footerFrame = CGRectMake(-self.collectionView.contentInset.left, maxH, self.collectionView.bounds.size.width, footerSize.height);
            framesForFooter[@(section)] = [NSValue valueWithCGRect:footerFrame];
            
            maxH += footerFrame.size.height;
        }
        
        
    }
    
    
    self.framesForFooter = framesForFooter;
    self.framesForHeader = framesForHeader;
    self.framesForItem   = framesForItem;
    
    self.contentSize = CGSizeMake(self.collectionView.bounds.size.width-self.collectionView.contentInset.left-self.collectionView.contentInset.right, maxH );
    
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    
    for (NSInteger section = 0, sections = [self.collectionView numberOfSections]; section < sections; section++) {
        
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        
        // header
        UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind: UICollectionElementKindSectionHeader atIndexPath:sectionIndexPath];
       
        if (!CGSizeEqualToSize(headerAttributes.frame.size, CGSizeZero) && CGRectIntersectsRect(headerAttributes.frame, rect)) {
            
            [layoutAttributes addObject:headerAttributes];
        }
        
        // items
//        for (int i = 0; i < [self.collectionView numberOfItemsInSection:section]; i++) {
//            
//            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
//            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
//            
//            if (CGRectIntersectsRect(rect, attributes.frame)) {
//                [layoutAttributes addObject:attributes];
//            }
//        }
        
        if([self.collectionView numberOfItemsInSection:section]){
      
            NSInteger mid = [self.collectionView numberOfItemsInSection:section]/2;
            NSInteger firstMatch = NSNotFound;
            
            NSInteger left = 0;
            NSInteger right = [self.collectionView numberOfItemsInSection:section];
            
            do {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:mid inSection:section];
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                
                if (CGRectIntersectsRect(rect, attributes.frame)) {
                    firstMatch = mid;
                } else {
                    if(attributes.frame.origin.y >= CGRectGetMaxY(rect)){
                        right = mid-1;
                    } else if(CGRectGetMaxY(attributes.frame) <= rect.origin.y){
                        left = mid+1;
                    }
                    
                    mid = (left+right)/2;
                }
            } while (mid >= 0 && mid < [self.collectionView numberOfItemsInSection:section] && firstMatch == NSNotFound && left < right);
            
            if(firstMatch != NSNotFound){
                //left part
                NSInteger killCount = 15;
                for(NSInteger j = firstMatch; j >= 0; j--){
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:section];
                    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                    if (CGRectIntersectsRect(rect, attributes.frame)) {
                        [layoutAttributes insertObject:attributes atIndex:0];
                    } else if(killCount == 0){
                        break;
                    } else {
                        killCount--;
                    }
                }
                
                killCount = 15;
                
                for(NSInteger j = firstMatch+1; j < [self.collectionView numberOfItemsInSection:section]; j++){
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:section];
                    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
                    if (CGRectIntersectsRect(rect, attributes.frame)) {
                        [layoutAttributes addObject:attributes];
                    } else if(killCount == 0){
                        break;
                    } else {
                        killCount--;
                    }
                }
            }
        }

        
        // footer
        UICollectionViewLayoutAttributes *footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:sectionIndexPath];
        
        if (! CGSizeEqualToSize(footerAttributes.frame.size, CGSizeZero) && CGRectIntersectsRect(footerAttributes.frame, rect)) {
            
            [layoutAttributes addObject:footerAttributes];
        }
        
    }
    
    return layoutAttributes;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.attributesForIndexPath[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        attributes.frame = [self.framesForHeader[@(indexPath.section)] CGRectValue];
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        attributes.frame = [self.framesForFooter[@(indexPath.section)] CGRectValue];
    }
    
    //如果没有header 或者 footer, 赋值nil, 防止崩溃
    if(CGRectIsEmpty(attributes.frame)) {
        attributes = nil;
    }
    
    return attributes;
}

-(CGSize)collectionViewContentSize
{
    return self.contentSize;
}


@end
