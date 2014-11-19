//
//  SemesterAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SemesterAttributeImporter: CompositeManagedObjectAttributeImporter {
    init() {
        let termCodeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "term_code", attributeKey: "termCode")
        super.init(attributeImporters: [termCodeImporter])
    }
}
