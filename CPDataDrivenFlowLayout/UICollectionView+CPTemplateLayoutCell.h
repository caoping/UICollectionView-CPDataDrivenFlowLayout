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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CPPreferredLayoutDimension) {
    CPPreferredLayoutDimensionWidth = 0,
    CPPreferredLayoutDimensionHeight
};

NS_ASSUME_NONNULL_BEGIN

/**
 Template auto layout Cell/SupplementaryView for automatically UICollectionViewCell/UICollectionReusableView height calculating (inspired by UITableView-FDTemplateLayoutCell)
 */
@interface UICollectionView (CPTemplateLayoutCell)

- (__kindof UICollectionReusableView *)cp_templateSupplementaryViewOfKind:(NSString *)kind
                                                          reuseIdentifier:(NSString *)identifier;

- (__kindof UICollectionViewCell *)cp_templateCellForReuseIdentifier:(NSString *)identifier;

#pragma mark - CollectionView Cell

/**
 calculating cell size by registered cell identifier and preferred layout dimension
 
 @param identifier               registered cell identifier
 @param preferredLayoutDimension dimension(Width or Height) used to calculating cell size
 @param preferredLayoutValue     dimension value
 @param configuration            configuration cell block
 
 @return CGSize
 */
- (CGSize)cp_sizeForCellWithIdentifier:(NSString *)identifier
              preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                  preferredLayoutValue:(CGFloat)preferredLayoutValue
                         configuration:(nullable void (^)(__kindof UICollectionViewCell *cell))configuration;

/**
 calculating cell size by registered cell identifier and preferred layout dimension, size will be cached by indexPath (Unimplemented)
 
 @param identifier               registered cell identifier
 @param preferredLayoutDimension dimension(Width or Height) used to calculating cell size
 @param preferredLayoutValue     dimension value
 @param indexPath                used to cache
 @param configuration            configuration cell block
 
 @return CGSize
 */
- (CGSize)cp_sizeForCellWithIdentifier:(NSString *)identifier
              preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                  preferredLayoutValue:(CGFloat)preferredLayoutValue
                      cacheByIndexPath:(NSIndexPath *)indexPath
                         configuration:(nullable void (^)(__kindof UICollectionViewCell *cell))configuration;

#pragma mark - Supplementary View

/**
 calculating view size by registered supplementary view identifier and preferred layout dimension
 
 @param kind                     registered supplementary view kind
 @param identifier               registered supplementary view identifier
 @param preferredLayoutDimension dimension(Width or Height) used to calculating view size
 @param preferredLayoutValue     dimension value
 @param configuration            configuration cell block
 
 @return CGSize
 */
- (CGSize)cp_sizeForSupplementaryViewOfKind:(NSString *)kind
                                 identifier:(NSString *)identifier
                   preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                       preferredLayoutValue:(CGFloat)preferredLayoutValue
                              configuration:(nullable void (^)(__kindof UICollectionReusableView *supplementaryView))configuration;

@end

NS_ASSUME_NONNULL_END
