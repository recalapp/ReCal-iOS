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
    let minimumQueryLength = 2
    
    // MARK: - Variables
    let managedObjectContext: NSManagedObjectContext
    let searchQuery: String
    let successHandler: [CDCourse]->Void
    let semesterTermCode: String
    
    init(searchQuery: String, semesterTermCode: String, managedObjectContext: NSManagedObjectContext, successHandler: [CDCourse]->Void) {
        self.managedObjectContext = managedObjectContext
        self.searchQuery = searchQuery
        self.successHandler = successHandler
        self.semesterTermCode = semesterTermCode
        super.init()
    }
    
    private var searchPredicate: NSPredicate {
        let queries = self.searchQuery.componentsSeparatedByString(" ").filter { countElements($0) >= self.minimumQueryLength }
        let predicates = queries.map { self.predicateForQuery($0) }
        return NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    }
    
    private func predicateForQuery(query: String) -> NSPredicate {
        let termCodePredicate = NSPredicate(format: "semester.termCode LIKE %@", self.semesterTermCode)!
        var queryPredicate: NSPredicate
        switch query {
        case _ where query.isNumeric():
            let numberPredicate = NSPredicate(format: "ANY courseListings.courseNumber CONTAINS[c] %@", query)
            queryPredicate = numberPredicate!
        case _ where countElements(query) == 3:
            let deptPredicate = NSPredicate(format: "ANY courseListings.departmentCode LIKE[c] %@", query)
            queryPredicate = deptPredicate!
        default:
            let deptPredicate = NSPredicate(format: "ANY courseListings.departmentCode CONTAINS[c] %@", argumentArray: [query])
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", argumentArray: [query])
            let descriptionPredicate = NSPredicate(format: "courseDescription CONTAINS[c] %@", query)!
            queryPredicate = NSCompoundPredicate.orPredicateWithSubpredicates([deptPredicate, titlePredicate, descriptionPredicate])
        }
        return NSCompoundPredicate.andPredicateWithSubpredicates([termCodePredicate, queryPredicate])
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
