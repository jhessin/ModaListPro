//
//  LoginViewController.swift
//  ModaListPro
//
//  Created by Jim Hessin on 12/2/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    // MARK: Outlets

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    // MARK: Loading

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()

        // TODO: Add sign in observer to load browser view
        FIRAuth.auth()?.addStateDidChangeListener {
            auth, user in
            if user != nil{
                self.performSegue(withIdentifier: "SignIn", sender: self)
            }
        }
    }

    // MARK: Actions

    @IBAction func loginPressed(_ sender: UIButton){
        if let email = emailField.text,
            let password = passwordField.text{
            FIRAuth.auth()?.signIn(withEmail: email, password: password) {
                user, error in
                if let error = error{
                    self.showError(error)
                }
            }
        } else{
            printMessage(title: "Invalid Entry", message: "Username and/or password invalid")
        }
    }

    @IBAction func unwindToLoginController(_ segue: UIStoryboardSegue){
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier{
        case .some("SignIn"):
            // TODO: Customize Segue
            return
        default:
            return
        }
    }
     */
}

extension UIViewController{

    // MARK: - Utilities

    func printMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showError(_ error: Error){
        printMessage(title: "Error", message: error.localizedDescription)
    }
}
