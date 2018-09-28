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
    
    func displaySummary(indexRow : Int){
        guard let workouts = workouts else {
            fatalError("Workout data unavailable.")
        }
        
        let workout = workouts[indexRow]
        
        let summary = summaries?[indexRow]
        let defaultQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 1)
        let ring = HKActivityRingView()
        if let activityGoal = summary?.activeEnergyBurnedGoal{
            let displaySummary = HKActivitySummary()
            displaySummary.activeEnergyBurned = workout.totalEnergyBurned ?? defaultQuantity
            displaySummary.activeEnergyBurnedGoal = activityGoal
            ring.setActivitySummary(displaySummary, animated: true)
        }else{
            let defaultSummary = HKActivitySummary()
            defaultSummary.activeEnergyBurned = workout.totalEnergyBurned ?? defaultQuantity
            defaultSummary.activeEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 600)
            ring.setActivitySummary(defaultSummary, animated: true)
        }
        ring.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        displaySummary(indexRow: indexPath.row)
    }
    
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

        let summary = summaries?[indexPath.row]
        let defaultQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 1)
        let ring = HKActivityRingView()
        if let activityGoal = summary?.activeEnergyBurnedGoal{
            let displaySummary = HKActivitySummary()
            displaySummary.activeEnergyBurned = workout.totalEnergyBurned ?? defaultQuantity
            displaySummary.activeEnergyBurnedGoal = activityGoal
            ring.setActivitySummary(displaySummary, animated: true)
        }else{
            let defaultSummary = HKActivitySummary()
            defaultSummary.activeEnergyBurned = workout.totalEnergyBurned ?? defaultQuantity
            defaultSummary.activeEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 600)
            ring.setActivitySummary(defaultSummary, animated: true)
        }
        ring.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        ring.setActivitySummary(summary, animated: false)
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
}
