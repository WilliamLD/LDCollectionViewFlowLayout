//
//  LDFirstCollectionViewController.m
//  LDCollectionViewFlowLayout
//
//  Created by LD on 15/3/24.
//  Copyright (c) 2015年 LD. All rights reserved.
//

#import "LDFirstCollectionViewController.h"
#import "LDCollectionViewFlowLayout.h"

@interface LDFirstCollectionViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation LDFirstCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    if(![self.collectionView.collectionViewLayout isKindOfClass:[LDCollectionViewFlowLayout class]]){
        LDCollectionViewFlowLayout *layout = [LDCollectionViewFlowLayout new];
        
        self.collectionView.collectionViewLayout = layout;
        
        [self.collectionView reloadData];
    } 
    
//    }
}


#pragma mark <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 4;
}

#define itemsInSection @[@1, @1, @5, @20]
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return  [itemsInSection[section] integerValue];;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    UIColor *randomColor = [UIColor colorWithRed:arc4random()%200/255.f green:arc4random()%200/255.f blue:arc4random()%255/255.f alpha:1];
    
    cell.backgroundColor = randomColor;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
        view.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.520];
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        view.backgroundColor = [UIColor greenColor];
    }
    
    return view;
}

#pragma mark - FlowlayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        return CGSizeMake(self.collectionView.bounds.size.width, 200);
    }
    if (indexPath.section == 1) {
        return CGSizeMake(self.collectionView.bounds.size.width, 80);
    }
    if (indexPath.section == 2 ) {
        if (indexPath.row == 0) {
            return CGSizeMake(self.collectionView.bounds.size.width/2 , 120);
        } else {
            return CGSizeMake(self.collectionView.bounds.size.width/2, 60);
        }
    }
    
    
    return CGSizeMake((self.collectionView.bounds.size.width-30)/2, 80);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0 || section == 1 || section == 2) {
        return UIEdgeInsetsZero;
    }
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    
    if (section == 3) {
        return 10;
    }
    return 0;
}
//
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 3) {
        return 10;
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return CGSizeZero;
            break;
        case 1:
        case 2:
        case 3:
            return CGSizeMake(320, 20);
            break;
        default:
            return CGSizeZero;
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{

    return CGSizeMake(300, 40);

}


@end
