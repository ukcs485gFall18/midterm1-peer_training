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

import HealthKit

class WorkoutDataStore {
  
  class func save(prancerciseWorkout: PrancerciseWorkout,
                  completion: @escaping ((Bool, Error?) -> Swift.Void)) {
    // Set up the calorie quantity for the total energy burned
    let calorieQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: prancerciseWorkout.totalEnergyBurned)
    
    // Build the workout using data from your Prancercise workout
    let workout = HKWorkout(activityType: .other, start: prancerciseWorkout.start, end: prancerciseWorkout.end, duration: prancerciseWorkout.duration, totalEnergyBurned: calorieQuantity, totalDistance: nil, device: HKDevice.local(), metadata: nil)
    
    // Save workout to HealthKit
    let healthStore = HKHealthStore()
    
    let samples = self.samples(for: prancerciseWorkout)
    
    healthStore.save(workout){ (success, error) in
        guard error == nil else{
            completion(false, error)
            return
        }
        
        healthStore.add(samples, to: workout, completion: { (samples, error) in
            guard error == nil else{
                completion(false, error)
                return
            }
            completion(true, nil)
        })
    }
}
    
    private class func samples(for workout: PrancerciseWorkout) -> [HKSample]{
        var samples = [HKSample]()
        
        // Verify that the energy quantity type is still available to HealthKit
        guard let energyQuantityType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) else{
            fatalError("Energy Burned Type is not available.")
        }
        
        // Create a sample for each PrancerciseWorkoutInterval
        for interval in workout.intervals{
            let calorieQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: interval.totalEnergyBurned)
            let sample = HKQuantitySample(type: energyQuantityType, quantity: calorieQuantity, start: interval.start, end: interval.end)
            samples.append(sample)
    }
        return samples
    }
    
    class func loadPrancerciseWorkouts(completion: @escaping (([HKWorkout]?, Error?) -> Swift.Void)){
        // Get workouts using Other activity type
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .other)
        
        // Get workouts from the Prancercise App
        let sourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())
        
        // combine into a single predicate
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate, sourcePredicate])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: compound, limit: 0, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
        DispatchQueue.main.async {
            // Cast samples as HKWorkout
            guard let samples = samples as? [HKWorkout], error == nil else{
                completion(nil, error)
                return
            }
            completion(samples, nil)
        }
    }
    HKHealthStore().execute(query)
}
    /*
     Retrieve ActivitySummaries from HealthKit - SQLoBue
     This function sets a start date and an end date, and then converts those dates into date components
     for use in HKQuery/HKActivitySummary Query.
    */
    class func readActivitySummaries(completion: @escaping (([HKActivitySummary]?, Error?) -> Swift.Void)){
        
        // set the date range for the query, currently hard coded for one week
        guard let calendar = NSCalendar(identifier: .gregorian) else{
            fatalError("Note: this is not expected to fail.")
        }
        let endDate = NSDate()
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate as Date, options: []) else{
            fatalError("Error calculating start date.")
        }
        
        // rebuild dates as date components
        let units : NSCalendar.Unit = [.day, .month, .year, .era]
        var startDateComps = calendar.components(units , from: startDate)
        var endDateComps = calendar.components(units , from: endDate as Date)
        startDateComps.calendar = calendar as Calendar
        endDateComps.calendar   = calendar as Calendar
        
        // set datePredicate for query
        let datePredicate = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComps, end: endDateComps)
        
        // build query
        let query = HKActivitySummaryQuery(predicate: datePredicate) { (query, summaries, error) in
            DispatchQueue.main.async {
                // Cast samples as ActivitySummaries
                guard let summaries = summaries as? [HKActivitySummary], error == nil else{
                    completion(nil, error)
                    return
                }
                completion(summaries, nil)
            }
        }
        HKHealthStore().execute(query)
    }
}
