//
//  MainViewController.swift
//  api
//
//  Created by Анна Заблуда on 26.05.2021.
//

import UIKit

class MainViewController: UIViewController {

    lazy var jokeLabel: UILabel = {
        let label: UILabel = UILabel(frame: CGRect.zero)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.sizeToFit()
        self.view.addSubview(label)
        return label
    }()

    // Идентификатор шутки понадобится для второй части статьи.
    var jokeID: Int = 0

    // ActivityView индикатор будет вращаться, пока не будет
    // получена шутка, затем он исчезнет.
    lazy var activityView: UIActivityIndicatorView = {
        let activityView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityView.hidesWhenStopped = true
        activityView.startAnimating()
        view.addSubview(activityView)
        return activityView
    }()

    lazy var stackView: UIStackView = {
        let mainStackView: UIStackView = UIStackView(arrangedSubviews: [self.jokeLabel])
        // Расстояние между элементами понадобиться во второй части
        mainStackView.spacing = 50
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        self.view.addSubview(mainStackView)
        return mainStackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

    self.title = "Chuck Norris Jokes"

        // В данном методе настраивается stackView и activityView,
        // что вызывает инициализацию их ленивых переменных.
        // В свою очередь инициализация stackView вызывает
        // инициализацию ленивой переменной label.
        self.configConstraints()    // (E.2)

        // Данный метод содержит весь функционал по работе
        // с интернетом и получению шутки.
        self.retrieveRandomJokes()    // (E.3)
    }

    func retrieveRandomJokes() {
        let http: HTTPCommunication = HTTPCommunication()
        // Посколько мы жестко кодируем url в код, то и сразу force unwrap его
        // Если url невалидный, то наше приложение уже бесполезно
        let url: URL = URL(string: "http://api.icndb.com/jokes/random")!

        http.retrieveURL(url) {
            // Чтобы избежать захвата self в замыкании, делаем weak self
            [weak self] (data) -> Void in
            
            // Получаем и распечатываем строковое представление json
            // данных, чтобы знать, в какой формат их переводить. Если
            // не можем получить нормальный json из загруженных данных,
            // то дальше уже не идем.
            guard let json = String(data: data, encoding: String.Encoding.utf8) else { return }
            // Пример распечатки: JSON:  { "type": "success", "value":
            // { "id": 391, "joke": "TNT was originally developed by Chuck
            // Norris to cure indigestion.", "categories": [] } }
            print("JSON: ", json)
                
            do {
                let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])

                // Проверяем, что мы можем переводить данные из Any
                // в нужный нам формат, иначе дальше не идем.
                guard
                    let jsonObject = jsonObjectAny as? [String: Any],
                    let value = jsonObject["value"] as? [String: Any],
                    let id = value["id"] as? Int,
                    let joke = value["joke"] as? String else {
                        return
                }
                    
                // Когда данные получены и расшифрованы,
                // мы останавливаем наш индикатор и он исчезает.
                self!.activityView.stopAnimating()
                self!.jokeID = id
                self!.jokeLabel.text = joke
            } catch {
                print("Can't serialize data.")
            }
        }
    }
}

extension MainViewController {
  
    func configConstraints() {
        // Задаем перевод autoresizingMask в ограничения(constraints)
        // как false, чтобы не создавать конфликт с нашими собственными
        // ограничениями
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor)
            ])

        self.activityView.translatesAutoresizingMaskIntoConstraints = false
        // Активируем массив ограничений (constraints) для activityView,
        // чтобы он показывался на месте label: центр по X и Y равен
        // центру label по X и Y.
        NSLayoutConstraint.activate([
            self.activityView.centerXAnchor.constraint(equalTo: self.jokeLabel.centerXAnchor),
            self.activityView.centerYAnchor.constraint(equalTo: self.jokeLabel.centerYAnchor)
            ])
    }
}
