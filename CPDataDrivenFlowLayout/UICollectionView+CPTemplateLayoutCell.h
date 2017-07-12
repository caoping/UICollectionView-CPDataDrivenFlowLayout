//
//  UICollectionView+CPTemplateLayoutCell.h
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

@interface UICollectionView (CPTemplateLayoutCell)

#pragma mark - Get Template Cell or SupplementaryView

- (__kindof UICollectionReusableView *)cp_templateSupplementaryViewOfKind:(NSString *)kind
                                                          reuseIdentifier:(NSString *)identifier;

- (__kindof UICollectionViewCell *)cp_templateCellForReuseIdentifier:(NSString *)identifier;

#pragma mark - Calculating CollectionView Cell Size

/**
 根据已注册collectionViewCell的identifier及期望的宽度or高度，返回cell的尺寸
 
 @param identifier               已注册collectionViewCell的identifier
 @param preferredLayoutDimension 用于计算期望cell尺寸的固定值类型枚举，Width or Height
 @param preferredLayoutValue     用于计算期望cell尺寸的固定值
 @param configuration            配置cell的block
 
 @return CGSize
 */
- (CGSize)cp_sizeForCellWithIdentifier:(NSString *)identifier
              preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                  preferredLayoutValue:(CGFloat)preferredLayoutValue
                         configuration:(nullable void (^)(__kindof UICollectionViewCell *cell))configuration;

/**
 根据已注册collectionViewCell的identifier及期望的宽度or高度，返回cell的尺寸 (cache暂未实现)
 
 @param identifier               已注册collectionViewCell的identifier
 @param preferredLayoutDimension 用于计算期望cell尺寸的固定值类型枚举，Width or Height
 @param preferredLayoutValue     用于计算期望cell尺寸的固定值
 @param indexPath                根据indexPath缓存cell size
 @param configuration            配置cell的block
 
 @return CGSize
 */
- (CGSize)cp_sizeForCellWithIdentifier:(NSString *)identifier
              preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                  preferredLayoutValue:(CGFloat)preferredLayoutValue
                      cacheByIndexPath:(NSIndexPath *)indexPath
                         configuration:(nullable void (^)(__kindof UICollectionViewCell *cell))configuration;

#pragma mark - Calculating Supplementary View Size


/**
 根据已注册SupplementaryView的identifier及期望的宽度or高度，返回view的尺寸
 
 @param kind                     SupplementaryViewKind
 @param identifier               已注册SupplementaryView的identifier
 @param preferredLayoutDimension 用于计算期望view尺寸的固定值类型枚举，Width or Height
 @param preferredLayoutValue     用于计算期望view尺寸的固定值
 @param configuration            配置view的block
 
 @return CGSize
 */
- (CGSize)cp_sizeForSupplementaryViewOfKind:(NSString *)kind
                                 identifier:(NSString *)identifier
                   preferredLayoutDimension:(CPPreferredLayoutDimension)preferredLayoutDimension
                       preferredLayoutValue:(CGFloat)preferredLayoutValue
                              configuration:(nullable void (^)(__kindof UICollectionReusableView *supplementaryView))configuration;

@end

NS_ASSUME_NONNULL_END
