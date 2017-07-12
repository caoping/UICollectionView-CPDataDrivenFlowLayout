// The MIT License (MIT)
//
// Copyright (c) 2016 caoping <caoping.dev@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "CPCollectionViewDelegateFlowLayoutInterceptor.h"
#import "UICollectionView+CPDataDrivenFlowLayout.h"

@implementation CPCollectionViewDelegateFlowLayoutInterceptor

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [collectionView cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.sectionInset;
    } else if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout sectionInset];
    }
    
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [collectionView cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.minimumLineSpacing;
    } else if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacing];
    }
    
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [collectionView cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.minimumInteritemSpacing;
    } else if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        return [(UICollectionViewFlowLayout *)collectionViewLayout minimumInteritemSpacing];
    }
    
    return 0;
}

//size for cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPCollectionViewCellInfo *cellInfo = [collectionView cp_cellInfoForItemAtIndexPath:indexPath];
    if (cellInfo.sizeForCellCallback) {
        //根据preferredLayout计算cell size的计算器
        CPCollectionViewPreferredLayoutBlock sizeByPreferredLayoutCalculator = ^(CPPreferredLayoutDimension dimension, CGFloat preferredLayoutValue) {
            CGSize size = CGSizeZero;
            
            if (cellInfo.cellReuseIdentifier) {
                size = [collectionView cp_sizeForCellWithIdentifier:cellInfo.cellReuseIdentifier preferredLayoutDimension:dimension preferredLayoutValue:preferredLayoutValue configuration:^(__kindof UICollectionViewCell * _Nonnull cell) {
                    if (cellInfo.cellDidReuseCallback) {
                        cellInfo.cellDidReuseCallback(collectionView, cell, indexPath, cellInfo.data);
                    }
                }];
            }
            
            return size;
        };
        
        return cellInfo.sizeForCellCallback(collectionView, collectionViewLayout, sizeByPreferredLayoutCalculator);
    }
    
    return CGSizeZero;
}

//size for header
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [collectionView cp_sectionInfoForSection:section];
    if (sectionInfo.sizeForHeaderCallback) {
        //根据preferredLayout计算cell size的计算器
        CPCollectionViewPreferredLayoutBlock sizeByPreferredLayoutCalculator = ^(CPPreferredLayoutDimension dimension, CGFloat preferredLayoutValue) {
            CGSize size = CGSizeZero;
            
            if (sectionInfo.headerReuseIdentifier) {
                size = [collectionView cp_sizeForSupplementaryViewOfKind:UICollectionElementKindSectionHeader identifier:sectionInfo.headerReuseIdentifier preferredLayoutDimension:dimension preferredLayoutValue:preferredLayoutValue configuration:^(__kindof UICollectionReusableView * _Nonnull supplementaryView) {
                    if (sectionInfo.headerDidReuseCallback) {
                        sectionInfo.headerDidReuseCallback(collectionView, supplementaryView, section);
                    }
                }];
            }
            
            return size;
        };
        
        return sectionInfo.sizeForHeaderCallback(collectionView, collectionViewLayout, sizeByPreferredLayoutCalculator);
    }
    
    return CGSizeZero;
}

//size for footer
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [collectionView cp_sectionInfoForSection:section];
    if (sectionInfo.sizeForFooterCallback) {
        //根据preferredLayout计算cell size的计算器
        CPCollectionViewPreferredLayoutBlock sizeByPreferredLayoutCalculator = ^(CPPreferredLayoutDimension dimension, CGFloat preferredLayoutValue) {
            CGSize size = CGSizeZero;
            
            if (sectionInfo.footerReuseIdentifier) {
                size = [collectionView cp_sizeForSupplementaryViewOfKind:UICollectionElementKindSectionFooter identifier:sectionInfo.footerReuseIdentifier preferredLayoutDimension:dimension preferredLayoutValue:preferredLayoutValue configuration:^(__kindof UICollectionReusableView * _Nonnull supplementaryView) {
                    if (sectionInfo.footerDidReuseCallback) {
                        sectionInfo.footerDidReuseCallback(collectionView, supplementaryView, section);
                    }
                }];
            }
            
            return size;
        };
        
        return sectionInfo.sizeForFooterCallback(collectionView, collectionViewLayout, sizeByPreferredLayoutCalculator);
    }
    
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CPCollectionViewCellInfo *cellInfo = [collectionView cp_cellInfoForItemAtIndexPath:indexPath];
    if (cellInfo && cellInfo.cellDidSelectCallback) {
        cellInfo.cellDidSelectCallback(collectionView, [collectionView cellForItemAtIndexPath:indexPath], indexPath, cellInfo.data);
    }
}

@end
