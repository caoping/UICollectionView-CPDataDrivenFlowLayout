//
//  ViewController.m
//  CPDataDrivenFlowLayout iOS Example
//
//  Created by caoping on 20/10/2016.
//
//

#import "ViewController.h"
#import <CPDataDrivenFlowLayout/CPDataDrivenFlowLayout.h>

@interface ViewController ()

@property (nonatomic) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    
    //开启dataDrivenFlowLayout
    [self.collectionView cp_enableDataDrivenFlowLayout];
    
    NSMutableArray *cellInfos = [NSMutableArray new];
    for (NSInteger i=0; i<20; i++) {
        //创建cell info
        CPCollectionViewCellInfo *cellInfo = [[CPCollectionViewCellInfo alloc] initWithCellClass:[UICollectionViewCell class] data:nil cellDidReuseCallback:^(__kindof UICollectionView * _Nonnull collectionView, __kindof UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, __kindof NSObject * _Nullable data) {
            cell.backgroundColor = [UIColor redColor];
        } sizeForCellCallback:^CGSize(__kindof UICollectionView * _Nonnull collectionView, __kindof UICollectionViewLayout * _Nonnull layout, CPCollectionViewPreferredLayoutBlock  _Nonnull sizeByPreferredLayoutCalculator) {
            return CGSizeMake(CGRectGetWidth(collectionView.bounds)/2-10, 50);
        }];
        [cellInfos addObject:cellInfo];
    }
    
    //创建section info
    CPCollectionViewSectionInfo *sectionInfo = [[CPCollectionViewSectionInfo alloc] initWithCellInfos:[cellInfos copy]];
    sectionInfo.minimumInteritemSpacing = 10;
    sectionInfo.minimumLineSpacing = 10;
    
    //reload
    [self.collectionView cp_reloadWithSectionInfos:@[sectionInfo]];
}


@end
