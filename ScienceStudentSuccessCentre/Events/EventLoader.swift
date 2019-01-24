//
//  EventParser.swift
//  ScienceStudentSuccessCentre
//
//  Created by Avery Vine on 2018-02-02.
//  Copyright © 2018 Avery Vine. All rights reserved.
//

import Foundation
import SwiftSoup
import PromiseKit
import Alamofire

/// Utility class that retrieves SSSC events from the server and parses them into proper `Event` objects.
class EventLoader {
    
    private static let serverUrl = "http://sssc-carleton-app-server.herokuapp.com/events"
    
    /// Asynchronously gathers event data from the server and parses the contents into proper `Event` objects.
    ///
    /// - Remark: Events downloaded and parsed by this function can be retrieved using `getEvents()`. This class will notify all observers when event data is ready to be retrieved.
    
    
    /// Gathers event data from the server and parses them into `Event` objects.
    ///
    /// - Returns: The newly parsed events in the form of a promise.
    public static func loadEvents() -> Promise<[Event]> {
        return Promise { seal in
            Alamofire.request(serverUrl).responseJSON { response in
                switch response.result {
                case .success(let json):
                    let events = parseEvents(json: json)
                    seal.fulfill(events)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    /// Converts JSON data into a chronologically sorted list of SSSC events.
    ///
    /// - Parameter json: JSON data retrieved from the server.
    /// - Returns: The list of events, parsed and sorted.
    private static func parseEvents(json: Any) -> [Event] {
        var events = [Event]()
        if let jsonEvents = json as? NSArray {
            for jsonEvent in jsonEvents {
                print(jsonEvent)
                if let eventData = jsonEvent as? NSDictionary {
                    let event = Event(eventData: eventData)
                    events.append(event)
                } else {
                    print("Failed to generate event...")
                }
            }
        } else {
            print("JSON data is invalid")
        }
        events = sortEvents(events)
        return events
    }
    
    /// Sorts the list of SSSC events into chronological order.
    ///
    /// This function sorts by year, then by month, then by day. If event $0 occurs sooner than $1, the return is `true` (indicating that event $0 should come before event $1 in the list). The return is `false` otherwise.
    /// - Parameter events: The list of events to sort.
    /// - Returns: The list of events in chronological order.
    private static func sortEvents(_ events: [Event]) -> [Event] {
        return events.sorted {
            if $0.getYear() < $1.getYear() {
                return true
            } else if $0.getYear() == $1.getYear() {
                if $0.getMonth() < $1.getMonth() {
                    return true
                } else if $0.getMonth() == $1.getMonth() {
                    if $0.getDay() < $1.getDay() {
                        return true
                    }
                }
            }
            return false
        }
    }
    
}
