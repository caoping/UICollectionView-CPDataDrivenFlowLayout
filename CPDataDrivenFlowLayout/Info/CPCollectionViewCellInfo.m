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

#import "CPCollectionViewCellInfo.h"

@implementation CPCollectionViewCellInfo

#pragma mark - Designated Initializer

- (instancetype)initWithCellClass:(nullable Class)cellClass nibForCell:(nullable UINib *)nibForCell cellReuseIdentifier:(nullable NSString *)cellReuseIdentifier data:(__kindof NSObject * _Nullable)data cellDidReuseCallback:(CPCollectionViewCellBlock)cellDidReuseCallback sizeForCellCallback:(nullable CPCollectionViewCellSizeBlock)sizeForCellCallback cellDidSelectCallback:(nullable CPCollectionViewCellBlock)cellDidSelectCallback {
    self = [super init];
    if (self) {
        NSParameterAssert(cellClass || nibForCell);
        
        _cellClass = cellClass;
        _nibForCell = nibForCell;
        _cellReuseIdentifier = cellReuseIdentifier;
        if (cellClass && !cellReuseIdentifier) {
            _cellReuseIdentifier = [NSStringFromClass(cellClass) stringByAppendingString:@"_CellReuseIdentifier"];
        }
        
        _data = data;
        _cellDidReuseCallback = [cellDidReuseCallback copy];
        _sizeForCellCallback = [sizeForCellCallback copy];
        _cellDidSelectCallback = [cellDidSelectCallback copy];
    }
    
    return self;
}

#pragma mark - Convenience Initializers With Class

- (instancetype)initWithCellClass:(Class)cellClass
                             data:(__kindof NSObject * _Nullable)data
             cellDidReuseCallback:(CPCollectionViewCellBlock)cellDidReuseCallback
              sizeForCellCallback:(CPCollectionViewCellSizeBlock)sizeForCellCallback {
    NSParameterAssert(cellClass);
    NSParameterAssert(cellDidReuseCallback);
    NSParameterAssert(sizeForCellCallback);
    
    return [self initWithCellClass:cellClass
                        nibForCell:nil
               cellReuseIdentifier:nil
                              data:data
              cellDidReuseCallback:cellDidReuseCallback
               sizeForCellCallback:sizeForCellCallback
             cellDidSelectCallback:nil];
}

- (instancetype)initWithCellClass:(Class)cellClass
              cellReuseIdentifier:(NSString *)cellReuseIdentifier
                             data:(__kindof NSObject * _Nullable)data
             cellDidReuseCallback:(CPCollectionViewCellBlock)cellDidReuseCallback
              sizeForCellCallback:(CPCollectionViewCellSizeBlock)sizeForCellCallback {
    NSParameterAssert(cellClass);
    NSParameterAssert(cellReuseIdentifier);
    NSParameterAssert(cellDidReuseCallback);
    NSParameterAssert(sizeForCellCallback);
    
    return [self initWithCellClass:cellClass
                        nibForCell:nil
               cellReuseIdentifier:cellReuseIdentifier
                              data:data
              cellDidReuseCallback:cellDidReuseCallback
               sizeForCellCallback:sizeForCellCallback
             cellDidSelectCallback:nil];
}

#pragma mark - Convenience Initializers With Nib

- (instancetype)initWithNibForCell:(UINib *)nibForCell
               cellReuseIdentifier:(NSString *)cellReuseIdentifier
                              data:(__kindof NSObject * _Nullable)data
              cellDidReuseCallback:(CPCollectionViewCellBlock)cellDidReuseCallback
               sizeForCellCallback:(CPCollectionViewCellSizeBlock)sizeForCellCallback {
    NSParameterAssert(nibForCell);
    NSParameterAssert(cellReuseIdentifier);
    NSParameterAssert(cellDidReuseCallback);
    NSParameterAssert(sizeForCellCallback);
    
    NSAssert([self checkNibIdentifierInDebug:nibForCell cellReuseIdentifier:cellReuseIdentifier], @"");
    return [self initWithCellClass:nil
                        nibForCell:nibForCell
               cellReuseIdentifier:cellReuseIdentifier
                              data:data
              cellDidReuseCallback:cellDidReuseCallback
               sizeForCellCallback:sizeForCellCallback
             cellDidSelectCallback:nil];
}

- (BOOL)checkNibIdentifierInDebug:(UINib *)nib cellReuseIdentifier:(NSString *)cellReuseIdentifier {
    NSArray *views = [nib instantiateWithOwner:nil options:nil];
    UICollectionReusableView *reusableView;
    for (UIView *view in views) {
        if ([view isKindOfClass:[UICollectionReusableView class]]) {
            reusableView = (UICollectionReusableView *)view;
            break;
        }
    }
    
    NSAssert(reusableView, @"%@ must contains UICollectionReusableView instance as root view", nib);
    NSAssert(reusableView.reuseIdentifier.length == 0 || [reusableView.reuseIdentifier isEqualToString:cellReuseIdentifier], @"%@ contains UICollectionReusableView instance reuseIdentifier is not equal to %@", nib, cellReuseIdentifier);
    
    return YES;
}


@end
