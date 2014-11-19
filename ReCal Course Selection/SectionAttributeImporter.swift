//
//  SectionAttributeImporter.swift
//  ReCal iOS
//
//  Created by Naphat Sanguansin on 11/19/14.
//  Copyright (c) 2014 ReCal. All rights reserved.
//

import UIKit
import ReCalCommon

class SectionAttributeImporter: CompositeManagedObjectAttributeImporter {
    init() {
        let nameImporter = StringManagedObjectAttributeImporter(dictionaryKey: "name", attributeKey: "name")
        let typeCodeImporter = StringManagedObjectAttributeImporter(dictionaryKey: "section_type", attributeKey: "sectionTypeCode", stringProcessing: { $0.lowercaseString })
        let meetingImporter = SectionMeetingAttributeImporter()
        let meetingToManyImporter = ToManyChildManagedObjectAttributeImporter(dictionaryKey: "meetings", attributeKey: "meetings", childEntityName: "CDSectionMeeting", childAttributeImporter: meetingImporter, childSearchPattern: ToManyChildManagedObjectAttributeImporter.ChildManagedObjectSearchPattern.SearchStringEqual("id", "serverId"), deleteMode: .Delete)
        super.init(attributeImporters: [nameImporter, typeCodeImporter, meetingToManyImporter])
    }
}
