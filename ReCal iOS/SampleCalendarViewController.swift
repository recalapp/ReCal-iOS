//
//  SampleCalendarViewController.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 10/16/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SampleCalendarViewController: UICollectionViewController {
    private let weekDataSource = SampleCalendarCollectionViewDataSource()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        if let collectionView = self.collectionView {
            collectionView.dataSource = self.weekDataSource
            collectionView.registerNib(UINib(nibName: "HeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: CollectionViewCalendarWeekLayoutSupplementaryViewKind.DayColumnHeader.toRaw(), withReuseIdentifier: dayHeaderViewIdentifier)
            if let layout = self.collectionView?.collectionViewLayout as? CollectionViewCalendarWeekLayout {
                layout.dataSource = self.weekDataSource
                layout.registerClass(HeaderBackgroundView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.DayColumnHeaderBackground.toRaw())
                layout.registerClass(GridLineView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.VerticalGridLine.toRaw())
                layout.registerClass(TimeHeaderBackgroundView.self, forDecorationViewOfKind: CollectionViewCalendarWeekLayoutDecorationViewKind.TimeRowHeaderBackground.toRaw())
            }
        }
        else {
            assert(false, "Collection View not initialized")
        }
        //self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(collectionView: UICollectionView!, shouldHighlightItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView!, shouldSelectItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(collectionView: UICollectionView!, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }

    func collectionView(collectionView: UICollectionView!, canPerformAction action: String!, forItemAtIndexPath indexPath: NSIndexPath!, withSender sender: AnyObject!) -> Bool {
        return false
    }

    func collectionView(collectionView: UICollectionView!, performAction action: String!, forItemAtIndexPath indexPath: NSIndexPath!, withSender sender: AnyObject!) {
    
    }
    */

}
