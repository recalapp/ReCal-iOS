//
//  CourseSearchOperation.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/4/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import CoreData

class CourseSearchOperation: NSOperation {
    
    // MARK: - Constants
    let minimumQueryLength = 3
    
    // MARK: - Variables
    let managedObjectContext: NSManagedObjectContext
    let searchQuery: String
    let successHandler: [CDCourse]->Void
    
    init(searchQuery: String, managedObjectContext: NSManagedObjectContext, successHandler: [CDCourse]->Void) {
        self.managedObjectContext = managedObjectContext
        self.searchQuery = searchQuery
        self.successHandler = successHandler
        super.init()
    }
    
    private var searchPredicate: NSPredicate {
        let queries = self.searchQuery.componentsSeparatedByString(" ").filter { countElements($0) > 0 }
        let predicates = queries.map {(query: String) -> NSPredicate in
            let deptPredicate = NSPredicate(format: "ANY courseListings.departmentCode CONTAINS[c] %@", argumentArray: [query])
            let numPredicate = NSPredicate(format: "ANY courseListings.courseNumber CONTAINS[c] %@", argumentArray: [query])
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", argumentArray: [query])
            return NSCompoundPredicate.orPredicateWithSubpredicates([deptPredicate, numPredicate, titlePredicate])
        }
        return NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        if countElements(self.searchQuery) < self.minimumQueryLength {
            self.successHandler([])
            return
        }
        let fetchRequest = NSFetchRequest(entityName: "CDCourse")
        fetchRequest.predicate = self.searchPredicate
        if self.cancelled {
            return
        }
        var errorOpt: NSError?
        var fetchedCoursesOpt: [CDCourse]?
        managedObjectContext.performBlockAndWait {
            if self.cancelled {
                return
            }
            fetchedCoursesOpt = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &errorOpt) as? [CDCourse]
        }
        if let error = errorOpt {
            println("Error executing search request. Error \(error)")
            return
        }
        
        if let fetchedCourses = fetchedCoursesOpt {
            if self.cancelled {
                return
            }
            self.successHandler(fetchedCourses)
        }
    }
}
