//
//  SplashViewController.swift
//  BiometricAuthTest
//
//  Created by Florentin Lupascu on 22/09/2021.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isUserAuthenticated = UserDefaults.standard.bool(forKey: "isUserAuthenticated")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if isUserAuthenticated {
                // go Home
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                self.navigationController?.setViewControllers([self.navigationController!.viewControllers.first!, homeVC], animated: true)
                
            } else {
                // go Login
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                self.navigationController?.setViewControllers([self.navigationController!.viewControllers.first!, loginVC], animated: true)
            }
        }
    }
}
