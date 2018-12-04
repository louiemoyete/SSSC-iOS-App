//
//  Course.swift
//  ScienceStudentSuccessCentre
//
//  Created by Avery Vine on 2018-10-01.
//  Copyright © 2018 Avery Vine. All rights reserved.
//

import Foundation
import UIKit

class Course {
    
    var id: String
    var name: String
    var code: String
    var credits: Double
    var isMajorCourse: Bool
    var finalGrade: String
    var termId: String
    var colour: UIColor.Material
    
    init(id: String?, name: String, code: String, credits: Double, isMajorCourse: Bool, finalGrade: String, termId: String, colour: UIColor.Material?) {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.code = code
        self.credits = credits
        self.isMajorCourse = isMajorCourse
        self.finalGrade = finalGrade
        self.termId = termId
        self.colour = colour ?? UIColor.Material.red
    }
    
    func getPercentGrade() -> Double {
        var totalEarned: Double = 0
        var totalWeight: Double = 0
        let assignments = Database.instance.getAssignmentsByCourseId(id: id)
        for assignment in assignments {
            let numAssignmentsWithWeight = Assignment.getAssignmentsByWeight(weight: assignment.weight, assignments: assignments).count
            let calculatedWeight = assignment.weight.value / Double(numAssignmentsWithWeight)
            totalEarned += Grading.calculatePercentage(earned: assignment.gradeEarned, total: assignment.gradeTotal) * calculatedWeight / 100
            totalWeight += calculatedWeight
        }
        return Grading.calculatePercentage(earned: totalEarned, total: totalWeight)
    }
    
    func getLetterGrade() -> String {
        if finalGrade != "None" {
            return finalGrade
        }
        return Grading.calculateLetterGrade(percentage: getPercentGrade())
    }
    
    func getGradeSummary() -> String {
        if finalGrade != "None" {
            return finalGrade
        }
        let percentGrade = getPercentGrade().rounded(toPlaces: 1)
        if percentGrade < 0 {
            return "N/A"
        }
        let letterGrade = getLetterGrade()
        return String(percentGrade) + "% (" + letterGrade + ")"
    }
    
    static func filterMajorCourses(courses: [Course]) -> [Course] {
        var majorCourses = [Course]()
        for course in courses {
            if course.isMajorCourse {
                majorCourses.append(course)
            }
        }
        return majorCourses
    }
    
    static func filterCompletedCourses(courses: [Course]) -> [Course] {
        var completedCourses = [Course]()
        for course in courses {
            if course.finalGrade != "None" {
                completedCourses.append(course)
            }
        }
        return completedCourses
    }
    
}

extension Course: Hashable {
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}