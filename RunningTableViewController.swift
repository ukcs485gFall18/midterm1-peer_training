//
//  RunningTableViewController.swift
//  Prancercise Tracker
//
//  Created by Willis, Bryan A on 9/29/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//
//bbb
import UIKit
import HealthKit

class RunningTableViewController: UITableViewController {
    
    private enum RunningWorkoutsSegues: String {
        case showCreateWorkout
        case finishedCreatingWorkout
    }
    
    private var workouts: [HKWorkout]?
    
    private let RunningWorkoutCellID = "RunningWorkoutCell"
    
    lazy var dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadWorkouts()
    }
    
    func reloadWorkouts() {
        WorkoutDataStore.loadRunningWorkouts { (workouts, error ) in
            self.workouts = workouts
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let workouts = workouts else{
            return 0
        }
        return workouts.count
    }
            
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        guard let workouts = workouts else{
            fatalError("CellForRowAtIndexPath should never get called if there are no workouts.")
        }
        
        // get a cell to display data
        let cell = tableView.dequeueReusableCell(withIdentifier: RunningWorkoutCellID, for: indexPath)
        
        // Get the corresponding workout
        let workout = workouts[indexPath.row]
        
        // Show the start date in the label
        cell.textLabel?.text = dateFormatter.string(from: workout.startDate)
        
        // show the calories burned in the lower label
        if let caloriesBurned = workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()){
            let formattedCalories = String(format: "Calories Burned: %.2f", caloriesBurned)
            cell.detailTextLabel?.text = formattedCalories
        }else{
            cell.detailTextLabel?.text = nil
        }
        return cell
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
