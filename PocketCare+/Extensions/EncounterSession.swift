/*
Copyright 2020 University at Buffalo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation
import UIKit

class EncounterSession {
    public static let sharedInstance = EncounterSession()
    
    // User defaults
    let defaults = UserDefaults.standard
    let gcmMessageIDKey = "gcm.message_id"
    
    /*
     - allHoursArr - contains all the hours that have been accounted for so far
     - This function checks allHoursArr to see if the current hour is already in the array,
     if not adds it to the array.
     
     Reason: To make sure when we send data to the server, we only send if atleast two different
     hours have been accounted for. Check getContactListParams() in AppDelegate.swift to see how
     we use allHoursArr to only send data when atleast two hours have been added.
     
     Not to confuse with the time at which we send the data, which happens at a regular interval
     with at least 2 different background functions and one check when user opens the app.
     */
    func addCurrentHour() {
        var allHoursArr = defaults.array(forKey: "allHoursArr")
        let currentHourEpoch = generateHourEpoch()

        if (allHoursArr != nil) {
            var hourDoesExist = false
            for hour in allHoursArr! {
                if (hour as! UInt64 == currentHourEpoch) {
                    hourDoesExist = true
                    break
                }
            }
            if (!hourDoesExist) {
                allHoursArr?.append(currentHourEpoch)
            }
            defaults.set(allHoursArr, forKey: "allHoursArr")
        } else {
            let allHoursArr = [currentHourEpoch]
            defaults.set(allHoursArr, forKey: "allHoursArr")
        }
    }
    
    /*****************************
     * Modified Implementation:
     * - Use average RSSI instead of maxRSSI 
     * Future Update:
     * Migration to Core Data / Realm.io
     *****************************/
    func processEncounter(VBT: String, rssi: Int, approxDistance: Double, currentZipCode: String, currentTime: UInt64, currentMinute: Int, deviceType: String) -> Bool {
        var hourlyContactInfoDict = defaults.dictionary(forKey: "hourlyContactInfo")
        var shouldNotify = false
        
        addCurrentHour()
        if (hourlyContactInfoDict != nil) {
            if (hourlyContactInfoDict?[VBT] != nil) {
                //Get the VBT dict
                var vbtDict = hourlyContactInfoDict?[VBT] as? [String: Any]
                //bug fix 1234
                let startTime = (vbtDict?["startTime"] as? UInt64) ?? currentTime
                let endTime = (vbtDict?["endTime"] as? UInt64) ?? currentTime
                var distancesDict = (vbtDict?["Distances"] as? [String:Double])!
                
                var allDistancesArr = Array(distancesDict.values)
                
                let notify = (vbtDict?["notify"] as? String)!
                var allSessions = (vbtDict?["allSessions"] as? [[String:Any]])!
                var maxRSSI = (vbtDict?["maxRSSI"] as? [String:Double])!
                let sumRSSI = (vbtDict?["sumRSSI"] as? Double)!
                let numRSSI = (vbtDict?["numRSSI"] as? Int)!
                
                let newSumRSSI = sumRSSI + Double(rssi)
                let newNumRSSI = numRSSI + 1
                
                let smDistance = (vbtDict?["smDistance"] as? Double)!

                let newCurrentTime = UInt64(Date().timeIntervalSince1970)
                let minutesPassedSinceLastSeen = (newCurrentTime-endTime)/60
                                
                // Check to see if there was a blackout period of greater than 5 minutes
                if (minutesPassedSinceLastSeen > 5) {
                    // We went over blackout period, check to see if reportable
                    // Check the last ongoing Sessions smooth distance and total time
                    // allDistancesArr hasn't been updated yet
                    let lastSessionSmoothDistance = calculateSmoothDistance(distances: allDistancesArr)
                    let totalDurationOfOngoingSession = ((currentTime-startTime)/60)+1
                    if (lastSessionSmoothDistance <= 2.0 && totalDurationOfOngoingSession >= 5) {
                        // It was a good session put it in allSessions
                        let countTwo = (endTime-startTime)/60
                        
                        allSessions.append(["startTime": startTime,"endTime": endTime, "isValid":"true", "avgDist": smDistance, "notify":notify, "countTwo": countTwo, "countTen": 0, "reason" : "The blackout time > 5 min"])
                        // We are replacing it with the current time because we are starting a new session with this beacon
                        let vbtDict = ["zipCode" : currentZipCode,
                                       "smDistance" : approxDistance,
                                       "Distances" : ["\(currentMinute)":approxDistance],
                                       "maxRSSI" : ["\(currentMinute)": rssi],
                                       "sumRSSI" : rssi,
                                       "numRSSI" : 1,
                                       "startTime": currentTime,
                                       "endTime": currentTime,
                                       "isValid": "false",
                                       "notify": "false",
                                       "deviceType" : deviceType,
                                       "allSessions" : allSessions
                                      ] as [String : Any]
                        
                        hourlyContactInfoDict?[VBT] = vbtDict
                        defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")
                        self.updateEncounters(totalDuration: Int(countTwo), endTime: endTime)
                        
                        // @GOOD - THIS HAS BEEN CHECKED
                    } else {
                        // Bad session put it in allSessions but as invalid and notify as false
                        let countTen = lastSessionSmoothDistance > 2 ? (endTime-startTime)/60: 0
                        let countTwo = lastSessionSmoothDistance <= 2 ? (endTime-startTime)/60: 0
                        if (countTwo != 0 && countTen != 0) {
                            allSessions.append(["startTime": startTime,"endTime": endTime, "isValid":"false", "avgDist": smDistance, "notify":notify, "countTwo": countTwo, "countTen":countTen, "reason" : "The blackout time > 5 min"])
                        }
                        // We are replacing it with the current time because we are starting a new session with this beacon
                        let vbtDict = ["zipCode" : currentZipCode,
                                       "smDistance" : approxDistance,
                                       "Distances" : ["\(currentMinute)":approxDistance],
                                       "maxRSSI" : ["\(currentMinute)": rssi],
                                       "sumRSSI" : rssi,
                                       "numRSSI" : 1,
                                       "startTime": currentTime,
                                       "endTime": currentTime,
                                       "isValid": "false",
                                       "notify": "false",
                                       "deviceType" : deviceType,
                                       "allSessions" : allSessions
                                      ] as [String : Any]
                        
                        hourlyContactInfoDict?[VBT] = vbtDict
                        defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")
                        // @GOOD - THIS HAS BEEN CHECKED

                    }
                } else {
                    // We have seen this same VBT within the last 5 minutes
                    
                    // Check smooth distance to make sure it's still less than 2.0
                    let lastSessionSmoothDistance = calculateSmoothDistance(distances: allDistancesArr)
                    if (lastSessionSmoothDistance <= 2.0) {
                        //Smooth distance is still less than 2.0
                        
                        // Update maxRSSI
                        if (maxRSSI["\(currentMinute)"] == nil) {
                            // maxRSSI doesn't exist
                            maxRSSI["\(currentMinute)"] = Double(rssi)
                            distancesDict["\(currentMinute)"] = approxDistance
                        } else {
                            let avgRSSI = newSumRSSI/Double(newNumRSSI)
                            maxRSSI["\(currentMinute)"] = avgRSSI
                            distancesDict["\(currentMinute)"] = deviceType == "iOS" ? convertRSSI_to_Distance_iOS(RSSI: Int(avgRSSI)) : convertRSSI_to_Distance_android(RSSI: Int(avgRSSI))
                        }
                        
                        // Get all distances
                        let newAllDistancesArr = Array(distancesDict.values)
                        
                        // Updates current smooth distance and all other variables
                        let currentSessionSmoothDistance = calculateSmoothDistance(distances: newAllDistancesArr)
                        vbtDict!["smDistance"] = currentSessionSmoothDistance
                        // Might be issue here since we are including the next minute too
                        let isValid = ((currentTime-startTime)/60)+1 >= 5 ? "true" : "false"
                        // BUG Check before updating startime if its set to 0
                        vbtDict!["startTime"] = startTime
                        vbtDict!["endTime"] = currentTime
                        vbtDict!["isValid"] = isValid
                        vbtDict!["maxRSSI"] = maxRSSI
                        vbtDict!["Distances"] = distancesDict
                        vbtDict!["zipCode"] = currentZipCode
                        vbtDict!["sumRSSI"] = newSumRSSI
                        vbtDict!["numRSSI"] = newNumRSSI


                        if ((currentTime-startTime)/60 >= 10) {
                            // @@CHECK TIME TO SEND NOTIFICATION
                            if ((vbtDict!["notify"] as? String) != "true") {
                                vbtDict!["notify"] = "true"
                                shouldNotify = true
                            }
                        }
                        
                        hourlyContactInfoDict?[VBT] = vbtDict
                        defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")
                    } else {
                        // The smooth distance is no longer less than 2.0
                        // Check to see if we atleast over 2 vals
                        // Terminate session make sure
                        // Check duration if >= 5
                        // checkSmoothDistance <= 2.0
                        if (allDistancesArr.count > 2) {
                            let totalDurationOfOngoingSession = ((endTime-startTime)/60)+1
                            allDistancesArr.sort(by: <) // Doesn't have to be array because we reorder it
                            allDistancesArr.remove(at: allDistancesArr.count-1)
                            
                            let lastSessionSmoothDistance = calculateSmoothDistance(distances: allDistancesArr)
                            
                            let countTen = lastSessionSmoothDistance > 2 ? totalDurationOfOngoingSession : 0
                            
                            let countTwo = lastSessionSmoothDistance <= 2 ? totalDurationOfOngoingSession : 0

                            if (totalDurationOfOngoingSession >= 5 && lastSessionSmoothDistance <= 2.0) {
                                //It was a good session
                                allSessions.append(["startTime": startTime,"endTime": endTime, "isValid":"true", "avgDist": lastSessionSmoothDistance, "notify":notify, "countTwo": countTwo, "countTen":countTen, "reason" : "The smoothed distance > 2m"])
                                self.updateEncounters(totalDuration: Int(countTwo), endTime: endTime)

                            } else {
                                if (countTwo != 0 && countTen != 0) {
                                    allSessions.append(["startTime": startTime,"endTime": endTime, "isValid":"false", "avgDist": lastSessionSmoothDistance, "notify":"false", "countTwo": countTwo, "countTen":countTen, "reason" : "The smoothed distance > 2m"])
                                }
                            }
                            
                            let vbtDict = ["zipCode" : currentZipCode,
                                             "smDistance" : approxDistance,
                                             "Distances" : ["\(currentMinute)":approxDistance],
                                             "maxRSSI" : ["\(currentMinute)": rssi],
                                             "sumRSSI" : rssi,
                                             "numRSSI" : 1,
                                             "startTime": currentTime,
                                             "endTime": currentTime,
                                             "isValid": "false",
                                             "notify": "false",
                                             "deviceType" : deviceType,
                                             "allSessions" : allSessions
                                            ] as [String : Any]
                            
                            hourlyContactInfoDict?[VBT] = vbtDict
                            defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")
                        } else {
                            // We dont have enought values to even calculate the smooth distance
                            // Keep updating
                            vbtDict!["startTime"] = startTime
                            vbtDict!["endTime"] = currentTime
                            vbtDict!["isValid"] = "false"
                            if (maxRSSI["\(currentMinute)"] == nil) {
                                // maxRSSI doesn't exist
                                maxRSSI["\(currentMinute)"] = Double(rssi)
                                distancesDict["\(currentMinute)"] = approxDistance
                                vbtDict!["sumRSSI"] = rssi
                                vbtDict!["numRSSI"] = 1
                            } else {
                                let avgRSSI = sumRSSI/Double(numRSSI)
                                maxRSSI["\(currentMinute)"] = avgRSSI
                                distancesDict["\(currentMinute)"] = deviceType == "iOS" ? convertRSSI_to_Distance_iOS(RSSI: Int(avgRSSI)) : convertRSSI_to_Distance_android(RSSI: Int(avgRSSI))
                            }
                            vbtDict!["maxRSSI"] = maxRSSI
                            vbtDict!["Distances"] = distancesDict
                            
                            hourlyContactInfoDict?[VBT] = vbtDict
                            defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")
                        }
                    }
                }
            } else {
                // This VBT DOESN"T EXIST
                //... This is a VBT we have not seen
                let vbtDict = ["zipCode" : currentZipCode,
                 "smDistance" : approxDistance,
                 "Distances" : ["\(currentMinute)":approxDistance],
                 "maxRSSI" : ["\(currentMinute)": rssi],
                 "sumRSSI" : rssi,
                 "numRSSI" : 1,
                 "startTime": currentTime,
                 "endTime": currentTime,
                 "isValid": "false",
                 "notify": "false",
                 "deviceType" : deviceType,
                 "allSessions" : [[String:Any]]()
                ] as [String : Any]
                hourlyContactInfoDict?[VBT] = vbtDict
                defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")
            }
        } else {
            // No dictionary exists
            let vbtDict = ["zipCode" : currentZipCode,
                           "smDistance" : approxDistance,
                           "Distances" : ["\(currentMinute)":approxDistance],
                           "maxRSSI" : ["\(currentMinute)": rssi],
                           "sumRSSI" : rssi,
                           "numRSSI" : 1,
                           "startTime": currentTime,
                           "endTime": currentTime,
                           "isValid": "false",
                           "notify": "false",
                           "deviceType" : deviceType,
                           "allSessions" : [[String:Any]]()
                          ] as [String : Any]
            
            let hourlyContactInfoDict = [VBT: vbtDict]
            defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")
        }
        return shouldNotify
    }
    
    // Distance to RSSI Return 10^[(Rssi-59-x)/y] where y = 40 and x = 4
    // RSSI[dbm] = −(10n log10(d) − A)
    
    // Calibration variables
    var androidX = 57.0
    var androidY = 35.0
    var iosX = 46.0
    var iosY = 30.0
    
    func convertRSSI_to_Distance_iOS(RSSI: Int) -> Double {
        return max(Double(1.0),pow(Double(10),Double(Double(Double(RSSI)-iosX)/iosY)).truncate(places: 2))
    }
    
    func convertRSSI_to_Distance_android(RSSI: Int) -> Double {
        return max(Double(1.0),pow(Double(10),Double(Double(Double(RSSI)-androidX)/androidY)).truncate(places: 2))
    }
    
    
    func generateHourEpoch() -> UInt64 {
        let today = Date()
        let hour = Calendar.current.component(.hour, from: today)
        let hourDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: today)!
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: -4, to: hourDate)!
        return UInt64(modifiedDate.toMillis())
    }
    
    /*****************************
     * Modified
     * Simple Moving Average
     *****************************/
    func calculateSmoothDistance(distances: [Double]) -> Double {
        var totalDistance = 0.0
        
        for dist in distances {
            totalDistance += dist
        }
        return totalDistance/Double(distances.count)
    }
    
    func generateDateEpoch() -> UInt64 {
        let today = Date()
        let date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
        let currentHour = Calendar.current.date(byAdding: .hour, value: -4, to: date)!
        print("Date:", currentHour)
        return UInt64(currentHour.toMillis())
    }
    
    //Returns Hour from given unix
    func hourStringFromUnixTime(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: -14400)
        dateFormatter.dateFormat = "h a"
        return dateFormatter.string(from: date as Date)
    }
    
    // Updates user defaults total duration and increase number of encounters by 1
    func updateEncounters (totalDuration: Int, endTime: UInt64) {
        //getCurrentHourAsString()
        let currentDate = Int(generateDateEpoch())
        var allEncounters = defaults.dictionary(forKey: "allEncounters")
        let currentHour = self.hourStringFromUnixTime(unixTime: Double(endTime))
        if (allEncounters != nil) {
            var currentHourEncounterSummary = allEncounters?[currentHour] as? [String: Int]
            if (currentHourEncounterSummary != nil) {
                let currTotalDuration = currentHourEncounterSummary?["totalDuration"]
                let currNumberOfEncounters = currentHourEncounterSummary?["numberOfEncounters"]
                currentHourEncounterSummary = ["totalDuration": totalDuration+currTotalDuration!, "numberOfEncounters": currNumberOfEncounters!+1, "date": currentDate]
                allEncounters?[currentHour] = currentHourEncounterSummary
            } else {
                allEncounters?[currentHour] = ["totalDuration": totalDuration, "numberOfEncounters": 1, "date": currentDate]
            }
            defaults.set(allEncounters, forKey: "allEncounters")

        } else {
            let allEncountersDict = [currentHour : ["totalDuration": totalDuration, "numberOfEncounters": 1, "date": currentDate]]
            defaults.set(allEncountersDict, forKey: "allEncounters")
        }
        
        print("THIS IS ALL ENCOUNTERS \(defaults.dictionary(forKey: "allEncounters") as AnyObject)")
    }
    
    func getCurrentHourAsString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: -14400)
        dateFormatter.dateFormat = "h a"
        return dateFormatter.string(from: date as Date)
    }
}
