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
    
    func getWeatherHistory(latitude: Double, longitude: Double, dateTime: String, completion: @escaping (Result<WeatherHistoryRepresentation, NetworkError>) -> Void) {
        
        let latitudeString = String(latitude)
        let longitudeString = String(longitude)
        
        var request = URLRequest(url: URL(string: "https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=\(latitudeString)&lon=\(longitudeString)&dt=\(dateTime)&appid=8944fa47fcfbfa7e3b1406342202eaf2&units=imperial")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("error fetching data: \(error)")
                completion(.failure(.noData))
                return
            }
            if let response = response as? HTTPURLResponse,
               !(200...210 ~= response.statusCode) {
                print("problem fetching data:\(response)")
                completion(.failure(.tryAgain))
            }
            guard let data = data else {
                print("no data from data task")
                completion(.failure(.noData))
                return
            }
            
            //Decode the Data
            do {
                let weatherHistoryResult = try JSONDecoder().decode(WeatherHistoryRepresentation.self, from: data)
                print(weatherHistoryResult.temperatureHigh)
                completion(.success(weatherHistoryResult))
            } catch {
                print("Error decoding weather data: \(error)")
                completion(.failure(.noData))
                return
            }
        }
        task.resume()
    }
    
}
