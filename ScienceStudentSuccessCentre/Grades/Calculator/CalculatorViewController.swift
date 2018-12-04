//
//  CalculatorViewController.swift
//  ScienceStudentSuccessCentre
//
//  Created by Avery Vine on 2018-09-27.
//  Copyright © 2018 Avery Vine. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var gpaDetailsView: UIView!
    @IBOutlet var overallGpaLabel: UILabel!
    @IBOutlet var majorGpaLabel: UILabel!
    
    private var courses = [Course]()
    private var terms = [Course : Term]()
    
    private let gpaFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        gpaFormatter.numberStyle = .decimal
        gpaFormatter.maximumFractionDigits = 1
        gpaFormatter.minimumFractionDigits = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCourses()
        updateGpaDetails()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalculatorTableViewCell", for: indexPath) as? CalculatorTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CalculatorTableViewCell.")
        }
        let course = courses[indexPath.row]
        let term = terms[course]
        cell.courseColourView.backgroundColor = UIColor(course.colour)
        cell.termAndCourseGrade.text = (term != nil ? ("[" + term!.shortForm + "] ") : "") + course.code
        cell.courseName.text = course.name
        cell.courseLetterGrade.text = course.getLetterGrade()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "calculatorDetail", sender: self)
    }
    
    private func loadCourses() {
        let defaults = UserDefaults.standard
        let includeInProgressCourses = defaults.bool(forKey: "includeInProgressCourses")
        
        courses.removeAll()
        courses = Database.instance.getCourses()
        if !includeInProgressCourses {
            courses = Course.filterCompletedCourses(courses: courses)
        }
        sortCoursesByTerm()
        self.tableView.reloadData()
    }
    
    private func sortCoursesByTerm() {
        let allTerms = Database.instance.getTerms()
        courses = courses.sorted { course1, course2  in
            if terms[course1] == nil {
                terms[course1] = allTerms.filter({ $0.id == course1.termId }).first
            }
            if terms[course2] == nil {
                terms[course2] = allTerms.filter({ $0.id == course2.termId }).first
            }
            if let term1 = terms[course1], let term2 = terms[course2] {
                if term1.year != term2.year {
                    return term1.year > term2.year
                }
                else {
                    if term1.term == "Fall" || (term1.term == "Summer" && term2.term == "Winter") {
                        return true
                    }
                    return false
                }
            }
            return false
        }
    }
    
    private func updateGpaDetails() {
        let overallGpa = Grading.calculateOverallGpa(courses: courses)
        
        let majorCourses = Course.filterMajorCourses(courses: courses)
        let majorGpa = Grading.calculateOverallGpa(courses: majorCourses)
        
        var newGpaText = "Overall CGPA: N/A"
        if overallGpa != -1 {
            if let overallGpaFormatted = gpaFormatter.string(from: overallGpa as NSNumber) {
                newGpaText = "Overall CGPA: " + overallGpaFormatted
            }
        }
        overallGpaLabel.text = newGpaText
        
        newGpaText = "Major CGPA: N/A"
        if majorGpa != -1 {
            if let majorGpaFormatted = gpaFormatter.string(from: majorGpa as NSNumber) {
                newGpaText = "Major CGPA: " + majorGpaFormatted
            }
        }
        majorGpaLabel.text = newGpaText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "calculatorDetail" {
            let controller = segue.destination as! CourseDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            controller.course = courses[indexPath.row]
        }
    }

}