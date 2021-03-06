/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import HealthKit
import HealthKitUI

class WorkoutsTableViewController: UITableViewController {

    // set tap recognizer to dismiss activity ring view - SQLoBue
    let tap = UITapGestureRecognizer(target: self, action:#selector(WorkoutsTableViewController.hideView))
    
    private enum WorkoutsSegues: String {
        case showCreateWorkout
        case finishedCreatingWorkout
    }
    
    private var workouts: [HKWorkout]?
    private var summaries: [HKActivitySummary]?
    
    private let prancerciseWorkoutCellID = "PrancerciseWorkoutCell"
    
    lazy var dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadWorkouts()
    }
    
    func reloadWorkouts() {
        WorkoutDataStore.readActivitySummaries{ (summaries, error) in
            self.summaries = summaries
        }
        WorkoutDataStore.loadPrancerciseWorkouts { (workouts, error ) in
            self.workouts = workouts
            self.tableView.reloadData()
        }
    }
    // set up UITableView DataSource
    override func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let workouts = workouts else{
            return 0
        }
        return workouts.count
    }
    
    /*
     Function to build and return an ActivityRingView based on indexRow data - SQLoBue
     */
    func displaySummary(indexRow : Int) -> UIView {
        guard let workouts = workouts else {
            fatalError("Workout data unavailable.")
        }
        
        let workout = workouts[indexRow]
        
        let defaultQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 100)
        if let summary = summaries?[indexRow]{
            let ring = HKActivityRingView()
            let activityGoal = summary.activeEnergyBurnedGoal
            let displaySummary = HKActivitySummary()
            displaySummary.activeEnergyBurned = workout.totalEnergyBurned ?? defaultQuantity
            displaySummary.activeEnergyBurnedGoal = activityGoal
            ring.setActivitySummary(displaySummary, animated: true)
            return ring
        }else{
            let defaultWorkoutCalories = workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? defaultQuantity.doubleValue(for: HKUnit.kilocalorie())
            let burnCalorieGoal = 600.0
            var colorIntensity = defaultWorkoutCalories / burnCalorieGoal
            if colorIntensity > 1{
                colorIntensity = 1.0
            }
            let imageName = #imageLiteral(resourceName: "reward_star")
            
            // build image from loaded Star, downloaded from Pixabay
            let tintImage = imageName.withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: tintImage)
            imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            imageView.image = tintImage
            imageView.tintColor = UIColor(hue: 200, saturation: 100, brightness: 20, alpha: CGFloat(colorIntensity))
            return imageView
        }
    }
    
    /*
     Call the displaySummary when the accessoryButton is tapped - SQLoBue
    */
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        let progressView = displaySummary(indexRow: indexPath.row)
        progressView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.view.addGestureRecognizer(tap)
        self.view = progressView
    }
    
    /*
     Function to hide Activity Ring View upon tap.
     Note: This should only trigger when the view is visible. - SQLoBue
    */
    @objc func hideView(on tap: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
 
    /*
     Updated function to display the detail disclosure button used to display activity ring - SQLoBue
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        guard let workouts = workouts else{
            fatalError("CellForRowAtIndexPath should never get called if there are no workouts.")
        }
        
        // Get a cell to display data
        let cell = tableView.dequeueReusableCell(withIdentifier: prancerciseWorkoutCellID, for: indexPath)
        
        // Get the corresponding workout
        let workout = workouts[indexPath.row]
        
        // show the start date in the label
        cell.textLabel?.text = dateFormatter.string(from: workout.startDate)
        
        // show the calories burned in the lower label
        guard let caloriesBurned = workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) else {
            cell.detailTextLabel?.text = nil
            return cell
        }
        let formattedCalories = String(format: "Calories Burned: %.2f", caloriesBurned)
        cell.detailTextLabel?.text = formattedCalories
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
} 
