//
//  ViewController.swift
//  GetPost
//
//  Created by Анна Заблуда on 27.05.2021.
//

import UIKit

class ViewController: UIViewController {


    @IBAction func getButton(_ sender: UIButton) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            guard let data = data else { return }
            print(data)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print (error)
            }
        }.resume()
        
    }
    @IBAction func postButton(_ sender: UIButton) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        let parameters = ["name" : "Anna", "years_old" : "20"]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let json = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = json
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            guard let data = data else { return }
            print(data)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print (error)
            }
        }.resume()
    }
    

}

