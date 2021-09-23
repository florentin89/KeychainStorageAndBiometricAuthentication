//
//  LoginViewController.swift
//  BiometricAuthTest
//
//  Created by Florentin Lupascu on 22/09/2021.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    @IBOutlet weak var memberCodeTextField: UITextField!
    @IBOutlet weak var memberPinTextField: UITextField!
    @IBOutlet weak var biometricLoginBtnOutlet: UIButton!
    
    let memberCode = "1234"
    let memberPin = "1234"
    
    var authentication = Authentication()
    var credentialsSavedInKeychain: Bool = false
    var loginError: Authentication.AuthenticationError?
    var credentials = Credentials()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayBiometricAuthButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBar(animated: animated)
    }
    
    @IBAction func biometricLoginBtnTouched(_ sender: UIButton) {
        print("Biometric Login Btn pressed...")
        
        authentication.requestBiometricUnlock { (result:Result<Credentials, Authentication.AuthenticationError>) in
            switch result {
            case .success(let credentials):
                self.credentials = credentials
                self.doLogin { success in
                    self.authentication.updateValidation(success: success)
                }
            case .failure(let error):
                self.loginError = error
            }
        }
    }
    
    // Login Btn Pressed
    @IBAction func loginBtnTouched(_ sender: UIButton) {
        
        guard let memberCode = memberCodeTextField.text, memberCode.count > 0 else {
            showAlertCustom(title: "Missing username", message: "Username is missing !")
            return
        }
        guard let memberPin = memberPinTextField.text, memberPin.count > 0 else {
            showAlertCustom(title: "Missing password.", message: "Password is missing !")
            return
        }
        
        credentials = Credentials(memberCode: memberCode, memberPin: memberPin)
        
        doLogin { success in
            self.authentication.updateValidation(success: success)
        }
    }
    
    // Check if we should display the Biometric Auth button or not. If there are no credentials saved in Keychain is no reason to display the button.
    func displayBiometricAuthButton() {
        
        let group = DispatchGroup()
        
        group.enter()
        
        // Operation 1: Get boolean value of credentialsSavedInKeychain
        self.credentialsSavedInKeychain = UserDefaults.standard.bool(forKey: "credentialsSavedInKeychain")
        group.leave()
        
        // Operation 2: Use the boolean above to display Biometric Authentication Button or not.
        group.notify(queue: DispatchQueue.main) {
            
            if self.credentialsSavedInKeychain {
                
                switch self.authentication.biometricType() {
                case .face:
                    print("Credentials saved in KeyChain -> We show biometricLoginBtn for FaceId")
                    if #available(iOS 13.0, *) {
                        self.biometricLoginBtnOutlet.setImage(UIImage(systemName: "faceid"),  for: .normal)
                    } else {
                        self.biometricLoginBtnOutlet.setImage(UIImage(named: "FaceIcon"),  for: .normal)
                    }
                case .touch:
                    print("Credentials saved in KeyChain -> We show biometricLoginBtn for FingerPrint")
                    if #available(iOS 13.0, *) {
                        self.biometricLoginBtnOutlet.setImage(UIImage(systemName: "touchid"),  for: .normal)
                    } else {
                        self.biometricLoginBtnOutlet.setImage(UIImage(named: "TouchIcon"),  for: .normal)
                    }
                default:
                    if #available(iOS 13.0, *) {
                        self.biometricLoginBtnOutlet.setImage(UIImage(systemName: "touchid"),  for: .normal)
                    } else {
                        self.biometricLoginBtnOutlet.setImage(UIImage(named: "TouchIcon"),  for: .normal)
                    }
                }
            } else {
                print("We don't show biometricLoginBtn because no credentials saved yet.")
                self.biometricLoginBtnOutlet.isHidden = true
            }
        }
        
        print("CredentialsSavedKeychain: \(credentialsSavedInKeychain)")
    }
    
    // Check login credentials
    func checkLoginCredentials(credentials: Credentials,
                               completion: @escaping (Result<Bool,Authentication.AuthenticationError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if credentials.memberCode == self.memberCode && credentials.memberPin == self.memberPin {
                completion(.success(true))
            } else {
                completion(.failure(.invalidCredentials))
            }
        }
    }
    
    // If user & pass are correct continue the login process
    func doLogin(completion: @escaping (Bool) -> Void) {
        
        checkLoginCredentials(credentials: credentials) { [unowned self](result:Result<Bool, Authentication.AuthenticationError>) in
            
            switch result {
            case .success:
                // if credentials are already saved in KeyChain don't show popup and go HomeScreen
                if credentialsSavedInKeychain {
                    // go HomeScreen
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                    self.navigationController?.setViewControllers([self.navigationController!.viewControllers.first!, homeVC], animated: true)
                }
                // If credentials are not saved in keychain then show alert and ask user if want to save Credentials in Keychain, otherwise next time when open the app LoginScreen will show up again
                else {
                    let saveCredentialsAlert = UIAlertController(title: "Save credentials", message: "Do you want to save username and password in Keychain for a fastest login?", preferredStyle: UIAlertController.Style.alert)
                    
                    saveCredentialsAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction!) in
                        
                        // Save credentials to Keychain
                        if KeychainStorage.saveCredentials(credentials) {
                            print("Password was saved in Keychain !")
                            // set a boolean in memory saying that the user is authenticated next time when will open the app
                            UserDefaults.standard.set(true, forKey: "isUserAuthenticated")
                            UserDefaults.standard.set(true, forKey: "credentialsSavedInKeychain")
                        } else {
                            print("Password wasn't saved in the Keychain because an error occured.")
                        }
                        
                        // go HomeScreen
                        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                        self.navigationController?.setViewControllers([self.navigationController!.viewControllers.first!, homeVC], animated: true)
                    }))
                    
                    saveCredentialsAlert.addAction(UIAlertAction(title: "Don't save", style: .cancel, handler: { (action: UIAlertAction!) in
                        // go HomeScreen
                        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                        self.navigationController?.setViewControllers([self.navigationController!.viewControllers.first!, homeVC], animated: true)
                    }))
                    present(saveCredentialsAlert, animated: true, completion: nil)
                }
            case .failure(let authError):
                credentials = Credentials()
                loginError = authError
                showAlertCustom(title: "Login Problem", message: "Wrong username or password.")
            }
        }
    }
    
    // Show alert if Login fail
    private func showAlertCustom(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message , preferredStyle:. alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
    
    // Function to hide the keypad when the user click anywhere on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            view.endEditing(true)
        }
    }
}
