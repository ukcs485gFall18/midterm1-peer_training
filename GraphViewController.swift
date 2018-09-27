//
//  GraphViewController.swift
//  Prancercise Tracker
//
//  Created by Hurst, Conner on 9/23/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import HealthKit

class GraphViewController: UIViewController {

    
    @IBOutlet weak var WorkoutNum23: UILabel!
    @IBOutlet weak var WorkoutNum24: UILabel!
    @IBOutlet weak var WorkoutNum25: UILabel!
    @IBOutlet weak var WorkoutNum26: UILabel!
    @IBOutlet weak var WorkoutNum27: UILabel!
    @IBAction func GetNumber(_ sender: UIButton) {
        loadWorkoutNum()
    }
    
    private var workouts: [HKWorkout]?
    
    // This function reads in saved workouts and determines the number that have been done each day
    func loadWorkoutNum() {
        WorkoutDataStore.loadPrancerciseWorkouts { (workouts, error ) in
            self.workouts = workouts
            
            // variable num for each bar
            var d_4 = 0
            var d_3 = 0
            var d_2 = 0
            var d_1 = 0
            var d0 = 0
            var other = 0
            
            self.workouts?.forEach { workout in
                let date = workout.startDate
                let todayDate = Date()
                let calendar = Calendar.current
                let today = calendar.component(.day, from: todayDate)
                let dateComponents = calendar.dateComponents([.day,.month],from: date)
                
                // figure out how many workouts have been done from 4 days ago to today
                switch (dateComponents.day) {
                case today-4:
                    d_4+=1
                case today-3:
                    d_3+=1
                case today-2:
                    d_2+=1
                case today-1:
                    d_1+=1
                case today:
                    d0+=1
                default:
                    other+=1
                }
            }
            
            // Populate labels
            self.WorkoutNum23.text = "\(d_4)"
            self.WorkoutNum24.text = "\(d_3)"
            self.WorkoutNum25.text = "\(d_2)"
            self.WorkoutNum26.text = "\(d_1)"
            self.WorkoutNum27.text = "\(d0)"
            
            // TODO
            // figure out how to make labels on left display dates from today through the past week
            // figure out how to create a bar graph with d0-d_4 as bar values
            // Probably create more labels so we have the most recent 7 days instead of 5
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
