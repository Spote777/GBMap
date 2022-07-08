//
//  LoginViewController.swift
//  GBMap
//
//  Created by Павел Заруцков on 18.06.2022.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    // MARK: - Propesties
    
    var router: ViewControllerRouterInput!
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        router = ViewControllerRouter(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLoginBindings()
        title = "Авторизация"
    }
    
    // MARK: - @IBAction
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        checkLoginData()
    }
    
    @IBAction func registrationButtonTapped(_ sender: Any) {
        registration()
    }
    
    private func checkLoginData() {
        var exist = false
        let loginText = loginTextfield?.text
        let passwordText = passwordTextfield?.text
        if loginText != nil && loginText != Optional("") {
            exist = RealmService.shared.userCredentialsExists(login: loginText!)
        } else {
            showIncorrectLogin()
            return
        }
        if exist == true {
            if passwordText != nil && passwordText != "" {
                let status = RealmService.shared.authorization(login: loginText!, password: passwordText!)
                if status {
                    router.navigateToViewController(value: 2)
                } else {
                    showIncorrectLogin()
                    return
                }
            }
        } else {
            showIncorrectLogin()
            return
        }
    }
    
    private func registration() {
        let alert = UIAlertController(title: "Регистрация", message: "Введите данные для регистрации", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { textfield in
            textfield.placeholder = "Введите логин"
        }
        alert.addTextField { textfield in
            textfield.placeholder = "Введите пароль"
            textfield.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Зарегистрироваться", style: .default, handler: { [weak alert] (_) in
            let user = User()
            guard let login = alert?.textFields![0].text, let password = alert?.textFields![1].text else { return }
            user._login = login
            user.password = password
            RealmService.shared.saveObject(user)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showIncorrectLogin() {
        let alert = UIAlertController(title: "Ошибка!", message: "Не правильный логин/пароль", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configureLoginBindings() {
             Observable
                 .combineLatest(
                     loginTextfield.rx.text,
                     passwordTextfield.rx.text
                 )
                 .map { login, password in
                     return !(login ?? "").isEmpty && (password ?? "").count >= 3
                 }
                 .bind { [weak loginButton] inputFilled in
                 loginButton?.isEnabled = inputFilled
                     if inputFilled == true {
                         loginButton?.alpha = 1
                     } else {
                         loginButton?.alpha = 0.5
                     }
             }
         }
}
