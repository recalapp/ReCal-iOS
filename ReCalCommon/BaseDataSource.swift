//
//  BaseDataSource.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/15/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit

class BaseDataSource: NSObject, UICollectionViewDataSource, DataSourceDelegate {
    typealias UpdateBlock = ()->Void
    
    private var updateQueue = Queue<UpdateBlock>()
    
    weak var delegate: DataSourceDelegate?
    /// Returns true if this data source is the root, meaning it is the one that collection view talks to explicitly
    var isRootDataSource: Bool {
        get {
            // TODO: verify logic
            if nil == self.delegate as? BaseDataSource {
                return false
            }
            return true
        }
    }
    
    /// Returns the correct data source for the section. The default implementation returns itself
    func dataSourceForSectionAtIndex(sectionIndex: Int) -> BaseDataSource
    {
        return self
    }
    
    /// Find the item at the specified index path. nil if not found
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject?
    {
        assert(false, "Should be implemented by subclass")
        return nil
    }
    
    /// Find the index paths of the specified item in the data source. An item may appear more than once in a given data source, or not at all, at which point the array returned is empty
    func indexPathsForItem(item: AnyObject) -> [NSIndexPath]
    {
        assert(false, "Should be implemented by subclass")
        return []
    }
    
    /// Remove an item from the data source. This method should only be called as the result of a user action, such as tapping the "Delete" button in a swipe-to-delete gesture. Automatic removal of items due to outside changes should instead be handled by the data source itself — not the controller. Data sources must implement this to support swipe-to-delete.
    func removeItemAtIndexPath(indexPath: NSIndexPath)
    {
        assert(false, "Should be implemented by subclass")
    }
    
    /// reset the content and loading state
    func resetContent()
    {
        
    }
    
    // MARK: Notifications methods
    // TODO: finish implementing
    private func executePendingUpdates()
    {
        ASSERT_MAIN_THREAD()
        while let updateBlock = self.updateQueue.dequeue() {
            updateBlock()
        }
    }
    
    private func enqueuePendingUpdateBlock(updateBlock: UpdateBlock)
    {
        self.updateQueue.enqueue(updateBlock)
    }
    
    func notifyItemsInsertedAtIndexPaths(indexPaths: [NSIndexPath])
    {
        ASSERT_MAIN_THREAD()
        self.delegate?.dataSource?(self, didInsertItemsAtIndexPaths: indexPaths)
    }
    
    func notifyItemsRemovedAtIndexPaths(indexPaths: [NSIndexPath])
    {
        ASSERT_MAIN_THREAD()
        self.delegate?.dataSource?(self, didRemoveItemsAtIndexPaths: indexPaths)
    }
    
    func notifyItemsRefreshedAtIndexPaths(indexPaths: [NSIndexPath])
    {
        ASSERT_MAIN_THREAD()
        self.delegate?.dataSource?(self, didRefreshItemsAtIndexPaths: indexPaths)
    }
    
    func notifyDidReloadData()
    {
        ASSERT_MAIN_THREAD()
        self.delegate?.dataSourceDidReloadData?(self)
    }
    
    func notifyBatchUpdate(update: UpdateBlock?, complete: UpdateBlock? = nil)
    {
        ASSERT_MAIN_THREAD()
        // TODO: is this logic correct?
        if let _ = self.delegate?.dataSource?(self, performBatchUpdate: update, complete: complete){
            
        }
        else {
            update?()
            complete?()
        }
    }
    
    func notifyContentLoadedWithError(error: NSError?)
    {
        ASSERT_MAIN_THREAD()
        self.delegate?.dataSource?(self, didLoadContentWithError: error)
    }
    
    func notifyWillLoadContent()
    {
        ASSERT_MAIN_THREAD()
        self.delegate?.dataSourceWillLoadContent?(self)
    }
    
    // MARK: UICollectionViewDataSource methods
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        assert(false, "Should be implemented by subclass")
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assert(false, "Should be implemented by subclass")
        return 0
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        assert(false, "Should be implemented by subclass")
        return 0
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        assert(false, "Should be implemented by subclass")
        // TODO: Apple's version has some default implementation
    }
}
