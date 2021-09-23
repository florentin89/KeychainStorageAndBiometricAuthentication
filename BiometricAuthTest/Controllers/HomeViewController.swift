//
//  HomeViewController.swift
//  BiometricAuthTest
//
//  Created by Florentin Lupascu on 22/09/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBar(animated: animated)
    }
    
    @IBAction func logoutBtnTouched(_ sender: UIButton) {
        print("Logout btn pressed")
        
        /// Here we can delete username and password from Keychain but after that when we re-run the app our biometric authentication implementation will have no sense 
        /// For more info about how the credentials are stored and when are completly deleted from your device please read this thread: https://developer.apple.com/forums/thread/36442
        // KeychainWrapper.standard.removeObject(forKey: KeychainStorage.key)
        
        UserDefaults.standard.set(false, forKey: "isUserAuthenticated")
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.navigationController?.setViewControllers([self.navigationController!.viewControllers.first!, loginVC], animated: true)
    }
}
