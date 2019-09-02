//
//  SectionOfPostAnnotation.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import RxDataSources

struct SectionOfPostAnnotation {
    var header: String
    var items: [Item]
}

extension SectionOfPostAnnotation: SectionModelType {
    typealias Item = PostAnnotation
    
    init(original: SectionOfPostAnnotation, items: [Item]) {
        self = original
        self.items = items
    }
}

extension SectionOfPostAnnotation: Comparable {
    static func < (lhs: SectionOfPostAnnotation, rhs: SectionOfPostAnnotation) -> Bool {
        return lhs.items.first!.date < rhs.items.first!.date
    }
    
    static func > (lhs: SectionOfPostAnnotation, rhs: SectionOfPostAnnotation) -> Bool {
        return lhs.items.first!.date > rhs.items.first!.date
    }
    
    static func == (lhs: SectionOfPostAnnotation, rhs: SectionOfPostAnnotation) -> Bool {
        return lhs.items.first!.date == rhs.items.first!.date
    }
}
