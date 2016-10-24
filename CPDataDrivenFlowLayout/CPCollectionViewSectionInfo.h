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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CPCollectionViewCellInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CPCollectionViewHeaderOrFooterBlock)(__kindof UICollectionView *collectionView, __kindof UICollectionReusableView *reusableView, NSInteger section);
typedef CGSize (^CPCollectionViewSizeForHeaderOrFooterBlock)(__kindof UICollectionView *collectionView, __kindof UICollectionViewLayout *layout, CPCollectionViewPreferredLayoutBlock sizeByPreferredLayoutCalculator);

@interface CPCollectionViewSectionInfo : NSObject

@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) NSArray<CPCollectionViewCellInfo *> *cellInfos;

@property (nonatomic, copy, nullable) NSString *identifier;//string used to identify section info
@property (nonatomic) CGFloat minimumLineSpacing;//The default value of this property is 0
@property (nonatomic) CGFloat minimumInteritemSpacing;//The default value of this property is 0
@property (nonatomic) UIEdgeInsets sectionInset;//The default edge insets are all set to 0.

@property (nonatomic, nullable) Class headerClass;
@property (nonatomic, nullable) UINib *nibForHeader;
@property (nonatomic, nullable) NSString *headerReuseIdentifier;
@property (nonatomic, copy, nullable) CPCollectionViewSizeForHeaderOrFooterBlock sizeForHeaderCallback;
@property (nonatomic, copy, nullable) CPCollectionViewHeaderOrFooterBlock headerDidReuseCallback;

@property (nonatomic, nullable) Class footerClass;
@property (nonatomic, nullable) UINib *nibForFooter;
@property (nonatomic, nullable) NSString *footerReuseIdentifier;
@property (nonatomic, copy, nullable) CPCollectionViewSizeForHeaderOrFooterBlock sizeForFooterCallback;
@property (nonatomic, copy, nullable) CPCollectionViewHeaderOrFooterBlock footerDidReuseCallback;

#pragma mark - Designated Initializer

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos NS_DESIGNATED_INITIALIZER;

#pragma mark - Convenience Initializers With Header

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos
                      headerClass:(Class)headerClass
           headerDidReuseCallback:(CPCollectionViewHeaderOrFooterBlock)headerDidReuseCallback
            sizeForHeaderCallback:(nullable CPCollectionViewSizeForHeaderOrFooterBlock)sizeForHeaderCallback;

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos
                     nibForHeader:(UINib *)nibForHeader
            headerReuseIdentifier:(NSString *)headerReuseIdentifier
           headerDidReuseCallback:(CPCollectionViewHeaderOrFooterBlock)headerDidReuseCallback
            sizeForHeaderCallback:(nullable CPCollectionViewSizeForHeaderOrFooterBlock)sizeForHeaderCallback;

#pragma mark - Convenience Initializers With Footer

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos
                      footerClass:(Class)footerClass
           footerDidReuseCallback:(CPCollectionViewHeaderOrFooterBlock)footerDidReuseCallback
            sizeForFooterCallback:(nullable CPCollectionViewSizeForHeaderOrFooterBlock)sizeForFooterCallback;

- (instancetype)initWithCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos
                     nibForFooter:(UINib *)nibForFooter
            footerReuseIdentifier:(NSString *)footerReuseIdentifier
           footerDidReuseCallback:(CPCollectionViewHeaderOrFooterBlock)footerDidReuseCallback
            sizeForFooterCallback:(nullable CPCollectionViewSizeForHeaderOrFooterBlock)sizeForFooterCallback;

#pragma mark - Appending And Inserting

- (void)cp_appendCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos;
- (void)cp_insertCellInfos:(NSArray<CPCollectionViewCellInfo *> *)cellInfos atIndexSet:(NSIndexSet *)indexSet;

#pragma mark - Update

- (BOOL)cp_updateCellInfo:(CPCollectionViewCellInfo *)cellInfo atIndex:(NSUInteger)index;

#pragma mark - Deleting

- (void)cp_deleteCellInfosAtIndexSet:(NSIndexSet *)indexSet;
- (void)cp_deleteCellInfo:(CPCollectionViewCellInfo *)cellInfo;

@end

NS_ASSUME_NONNULL_END
