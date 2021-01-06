//
//  APIController.swift
//  MyForage
//
//  Created by Cora Jacobson on 12/15/20.
//

import Foundation


final class ApiController {
    
    enum NetworkError: Error {
        case noData
        case tryAgain
        case badUrl
    }
 
    func getWeatherHistory(latitude: String, longitude: String, dateTime: String, completion: @escaping (Result<WeatherHistoryRepresentation, NetworkError>) -> Void) {
        
        var semaphore = DispatchSemaphore (value: 0)

        var request = URLRequest(url: URL(string: "https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=\(latitude)&lon=\(longitude)&dt=\(dateTime)&appid=8944fa47fcfbfa7e3b1406342202eaf2&units=imperial")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("error fetching data: \(error)")
                completion(.failure(.noData))
                return
            }
            if let response = response {
                print("problem fetching data:\(response)")
                completion(.failure(.tryAgain))
            }
            guard let data = data else {
                print("no data from data task")
                completion(.failure(.noData))
                return
            }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        
        //Decode the Data
            do {
                let weatherHistoryResult = try JSONDecoder().decode(WeatherHistoryRepresentation.self, from: data)
                completion(.success(weatherHistoryResult))
            } catch {
                print("Error decoding weather data: \(error)")
                completion(.failure(.noData))
                return
            }
        }
        task.resume()
        semaphore.wait()
    }
}
