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

    
    @IBOutlet weak var BarChart: BasicBarChart!
    
    private var workouts: [HKWorkout]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        WorkoutDataStore.loadPrancerciseWorkouts { (workouts, error ) in
            self.workouts = workouts
            
            // variable num for each bar
            var d_6 = 0
            var d_5 = 0
            var d_4 = 0
            var d_3 = 0
            var d_2 = 0
            var d_1 = 0
            var d0 = 0
            var other = 0
            
            
            let todayDate = Date()
            let calendar = Calendar.current
            let today = calendar.component(.day, from: todayDate)
            
            self.workouts?.forEach { workout in
                let date = workout.startDate
                let dateComponents = calendar.dateComponents([.day,.month],from: date)
                
                // figure out how many workouts have been done over the past week
                switch (dateComponents.day) {
                case today-6:
                    d_6+=1
                case today-5:
                    d_5+=1
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
            
            // Array that stores bar values
            let workoutNums = [d_6,d_5,d_4,d_3,d_2,d_1,d0]
            
            let dataEntries = self.generateDataEntries(workoutNums: workoutNums)
            self.BarChart.dataEntries = dataEntries
        }
    }

    // Function that generates graph
    func generateDataEntries(workoutNums: [Int]) -> [BarEntry] {
        let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)]
        var result: [BarEntry] = []
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMd"
        var date = Date()
        date.addTimeInterval(TimeInterval(-6*24*60*60))
        // Creates 7 bars with values from workoutNums for each day over the past week
        for i in 0...6{
            result.append(BarEntry(color: colors[i], height: Float(workoutNums[i])/10, textValue: "\(workoutNums[i])", title: formatter.string(from: date)))
            date.addTimeInterval(TimeInterval(24*60*60))
        }
        return result
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
