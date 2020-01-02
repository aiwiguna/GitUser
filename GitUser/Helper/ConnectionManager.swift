//
//  ConnectionManager.swift
//  GitUser
//
//  Created by Antoni on 02/01/20.
//  Copyright © 2020 aiwiguna. All rights reserved.
//

import Foundation

class ConnectionManager{
    static func getUsers(userNumber:Int = 0 ,completion: @escaping (Users?, Error?)-> Void){
        let session = URLSession(configuration: .default)
        let components = URLComponents(string: "https://api.github.com/users?since=\(userNumber)")!
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"

        let task = session.dataTask(with: request) { (data, response, err) in
            if let error = err{
                completion(nil, error)
            }else if let unwrappedData = data{
                do{
                    let response = try JSONDecoder().decode(Users.self, from: unwrappedData)
                    completion(response,nil)
                }catch{
                    completion(nil,error)
                }
            }
        }
        task.resume()
    }
}
