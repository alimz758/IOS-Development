//
//  LogInViewController.swift
//  Chat-App
//
//  This is the view controller where users login


import UIKit
import Firebase // to Login
import SVProgressHUD
class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func logInPressed(_ sender: AnyObject) {
        //for UI design , this would show a loading circle
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
            //if there was an error to login
            (user, error) in
            if error != nil{
                print(error!)
            }else{
                print("Successful")
                //remove the loading circle
                SVProgressHUD.dismiss()
                //go to the next viewControler with the following identifier
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    }
}  
