//
//  Assignment.swift
//  ScienceStudentSuccessCentre
//
//  Created by Avery Vine on 2018-10-03.
//  Copyright © 2018 Avery Vine. All rights reserved.
//

import Foundation

class Assignment {
    var id: Int
    var name: String
    var gradeEarned: Double
    var gradeTotal: Double
    var weight: Double
    var courseId: Int
    
    init(id: Int, name: String, gradeEarned: Double, gradeTotal: Double, weight: Double, courseId: Int) {
        self.id = id
        self.name = name
        self.gradeEarned = gradeEarned
        self.gradeTotal = gradeTotal
        self.weight = weight
        self.courseId = courseId
    }
    
}
