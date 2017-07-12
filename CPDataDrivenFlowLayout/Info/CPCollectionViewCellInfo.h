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
#import "UICollectionView+CPTemplateLayoutCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CPCollectionViewCellBlock)(__kindof UICollectionView *collectionView, __kindof UICollectionViewCell *cell, NSIndexPath *indexPath, __kindof NSObject * _Nullable data);
typedef CGSize (^CPCollectionViewPreferredLayoutBlock)(CPPreferredLayoutDimension dimension, CGFloat preferredLayoutValue);
typedef CGSize (^CPCollectionViewCellSizeBlock)(__kindof UICollectionView *collectionView, __kindof UICollectionViewLayout *layout, CPCollectionViewPreferredLayoutBlock sizeByPreferredLayoutCalculator);

@interface CPCollectionViewCellInfo : NSObject

@property (nonatomic, readonly) NSString *cellReuseIdentifier;

@property (nonatomic, nullable) NSString *identifier;//string used to identify cell info
@property (nonatomic, nullable) __kindof NSObject *data;

@property (nonatomic, nullable) Class cellClass;
@property (nonatomic, nullable) UINib *nibForCell;

@property (nonatomic, copy) CPCollectionViewCellBlock cellDidReuseCallback;
@property (nonatomic, copy, nullable) CPCollectionViewCellSizeBlock sizeForCellCallback;
@property (nonatomic, copy, nullable) CPCollectionViewCellBlock cellDidSelectCallback;

#pragma mark - Initializers With Class

- (instancetype)initWithCellClass:(Class)cellClass
                             data:(__kindof NSObject * _Nullable)data
             cellDidReuseCallback:(CPCollectionViewCellBlock)cellDidReuseCallback
              sizeForCellCallback:(CPCollectionViewCellSizeBlock)sizeForCellCallback;

- (instancetype)initWithCellClass:(Class)cellClass
              cellReuseIdentifier:(NSString *)cellReuseIdentifier
                             data:(__kindof NSObject * _Nullable)data
             cellDidReuseCallback:(CPCollectionViewCellBlock)cellDidReuseCallback
              sizeForCellCallback:(CPCollectionViewCellSizeBlock)sizeForCellCallback;

#pragma mark - Initializers With Nib

- (instancetype)initWithNibForCell:(UINib *)nibForCell
               cellReuseIdentifier:(NSString *)cellReuseIdentifier
                              data:(__kindof NSObject * _Nullable)data
              cellDidReuseCallback:(CPCollectionViewCellBlock)cellDidReuseCallback
               sizeForCellCallback:(CPCollectionViewCellSizeBlock)sizeForCellCallback;

@end

NS_ASSUME_NONNULL_END
