//
//  APIController.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import Foundation


final class ApiController {
    
 
    func getWeatherHistory(latitude: String, longitude: String, dateTime: String) {
        
        var semaphore = DispatchSemaphore (value: 0)

        var request = URLRequest(url: URL(string: "https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=\(latitude)&lon=\(longitude)&dt=\(dateTime)&appid=8944fa47fcfbfa7e3b1406342202eaf2&units=imperial")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
}
