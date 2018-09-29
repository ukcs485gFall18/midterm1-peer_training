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

import Foundation

enum WorkoutSessionState {
  case notStarted
  case active
  case finished
}

class WorkoutSession {
  
  private (set) var startDate: Date!
  private (set) var endDate: Date!
  
  var state: WorkoutSessionState = .notStarted
  var intervals = [PrancerciseWorkoutInterval]()
  var runningIntervals = [RunningWorkoutInterval]()
    
  func start() {
    startDate = Date()
    state = .active
  }
  
  // This function was modified by Bryan Willis
  func end(flag: Int) {
    endDate = Date()
    addNewInterval(flag: flag)
    state = .finished
  }
  
  func clear() {
    startDate = nil
    endDate = nil
    state = .notStarted
    intervals.removeAll()
    runningIntervals.removeAll()
  }
  
    // This function was modified by Bryan Willis
    private func addNewInterval(flag: Int){
        if(flag == 0){
            let interval = PrancerciseWorkoutInterval(start: startDate, end: endDate)
            intervals.append(interval)
        } else {
            let interval = RunningWorkoutInterval(start: startDate, end: endDate)
            runningIntervals.append(interval)
        }
    }
    
  var completeWorkout: PrancerciseWorkout? {
    
    get {
      
      guard state == .finished,
        intervals.count > 0 else{
            return nil
        }
        return PrancerciseWorkout(with: intervals)
    }
  }
    //This function was added by Bryan Willis
    var completeRunningWorkout: RunningWorkout? {
        get {
            
            guard state == .finished,
                runningIntervals.count > 0 else{
                    return nil
            }
            return RunningWorkout(with: runningIntervals)
        }
    }
  
}
