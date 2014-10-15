//
//  DataSourceDelegate.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//
import UIKit
@objc protocol DataSourceDelegate: class{
    optional func dataSource(dataSource: BaseDataSource, didInsertItemsAtIndexPaths indexPaths:[NSIndexPath])
    optional func dataSource(dataSource: BaseDataSource, didRemoveItemsAtIndexPaths indexPaths:[NSIndexPath])
    optional func dataSource(dataSource: BaseDataSource, didRefreshItemsAtIndexPaths indexPaths:[NSIndexPath])
    
    optional func dataSourceDidReloadData(dataSource: BaseDataSource)
    optional func dataSource(dataSource: BaseDataSource, performBatchUpdate update: (()->Void)?, complete: (()->Void)?)
    
    /// If the content was loaded successfully, the error will be nil.
    optional func dataSource(dataSource: BaseDataSource, didLoadContentWithError error: NSError?)
    
    /// Called just before a datasource begins loading its content.
    optional func dataSourceWillLoadContent(dataSource: BaseDataSource)
}