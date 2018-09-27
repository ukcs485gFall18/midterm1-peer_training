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

    @IBOutlet weak var WorkoutNum: UILabel!
    
    private var workouts: [HKWorkout]?
    
    func loadWorkoutNum() {
        WorkoutDataStore.loadPrancerciseWorkouts { (workouts, error ) in
            self.workouts = workouts
            self.WorkoutNum.text = "/(self.workouts?.count)"
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
