//
//  CreateAccountController.swift
//  ModaListPro
//
//  Created by Jim Hessin on 12/7/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import UIKit

class CreateAccountController: LoginViewController {

    // MARK: Outlets

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!

    // MARK: Loading
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: Actions
    @IBAction func createPressed(_ sender: UIButton){
        guard let username = usernameField?.text,
            let email = emailField?.text,
            let password = passwordField?.text,
            let confirm = confirmPasswordField?.text,
            password == confirm else {
                // Print error message
                printMessage(title: "Invalid data", message: "Ensure that all fields have been filled and the passwords match.")
                return
        }

        System.auth.createUser(withEmail: email, password: password) {
            user, error in
            if let error = error {
                self.showError(error)
            } else if let user = user{
                let request = user.profileChangeRequest()
                request.displayName = username
                request.commitChanges {
                    error in
                    if let error = error{
                        self.showError(error)
                    } else{
                        self.loginPressed(sender)
                    }
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
