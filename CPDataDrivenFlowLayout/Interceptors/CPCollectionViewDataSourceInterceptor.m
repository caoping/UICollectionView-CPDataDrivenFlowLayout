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

#import "CPCollectionViewDataSourceInterceptor.h"
#import "UICollectionView+CPDataDrivenFlowLayout.h"

@implementation CPCollectionViewDataSourceInterceptor

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([collectionView cp_sectionInfos].count > 0) {
        return [collectionView cp_sectionInfos].count;
    }
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    CPCollectionViewSectionInfo *sectionInfo = [collectionView cp_sectionInfoForSection:section];
    if (sectionInfo) {
        return sectionInfo.numberOfItems;
    }
    
    return 0;
}

//cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPCollectionViewCellInfo *cellInfo = [collectionView cp_cellInfoForItemAtIndexPath:indexPath];
    if (cellInfo) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellInfo.cellReuseIdentifier forIndexPath:indexPath];
        if (cellInfo.cellDidReuseCallback) {
            cellInfo.cellDidReuseCallback(collectionView, cell, indexPath, cellInfo.data);
        }
        
        return cell;
    }
    
    return nil;
}

//header or footer
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    CPCollectionViewSectionInfo *sectionInfo = [collectionView cp_sectionInfoForSection:indexPath.section];
    if (sectionInfo) {
        if (sectionInfo.headerReuseIdentifier && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
            //header
            UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                  withReuseIdentifier:sectionInfo.headerReuseIdentifier
                                                                                         forIndexPath:indexPath];
            if (sectionInfo.headerDidReuseCallback) {
                sectionInfo.headerDidReuseCallback(collectionView, header, indexPath.section);
            }
            return header;
            
        } else if (sectionInfo.footerReuseIdentifier && [kind isEqualToString:UICollectionElementKindSectionFooter]) {
            //footer
            UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                  withReuseIdentifier:sectionInfo.footerReuseIdentifier
                                                                                         forIndexPath:indexPath];
            if (sectionInfo.footerDidReuseCallback) {
                sectionInfo.footerDidReuseCallback(collectionView, footer, indexPath.section);
            }
            return footer;
        }
    }
    
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:_CPPlaceholderSupplementaryView forIndexPath:indexPath];
}

@end
