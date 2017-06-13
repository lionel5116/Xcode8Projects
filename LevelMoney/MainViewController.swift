//
//  ViewController.swift
//  LevelMoney
//
//  Created by lionel on 6/3/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController,UITextFieldDelegate {

    var refLogins: DatabaseReference!
    
    var oLogin = Login();
    var bFound = false;
    
    @IBOutlet weak var lblLoginError: UILabel!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showHideLoginFields(show:true);
        
        //for dismissing the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)));
        refLogins  = Database.database().reference().child("LoginTable")
        print("Making a change to test out source control");
        
    }
    
    
    func dismissKeyboard()
    {
        self.txtUserName.resignFirstResponder();
        self.txtPassword.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtUserName.resignFirstResponder();
        self.txtPassword.resignFirstResponder();
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showLoginFields(_ sender: Any) {
        showHideLoginFields(show:false);
    }

    func proceedToBankSetup()
    {
        let oAccounts = Accounts();
        oAccounts.loginName = self.txtUserName.text;
        
        let objBankSetupViewController = self.storyboard?.instantiateViewController(withIdentifier: "BankSetupViewController") as! BankSetupViewController;
        objBankSetupViewController.oAccounts = oAccounts;
        self.navigationController?.pushViewController(objBankSetupViewController, animated: true);
    }
    
    @IBAction func goToAccounts(_ sender: Any) {
        self.lblLoginError.textColor = UIColor.black;
        self.lblLoginError.text = "";
        if(self.txtUserName.text != "" &&
            self.txtPassword.text != "")
        {
            _ = verifyLoginNamePassword(userName:self.txtUserName.text!,passWord:self.txtPassword.text!)
        }
        else
        {
            self.lblLoginError.textColor = UIColor.red;
            self.lblLoginError.text = "Please enter username and password";
        }
    }
    
    func verifyLoginNamePassword(userName:String,passWord:String){
       fetchLoginFireBase(userName:self.txtUserName.text!,password:self.txtPassword.text!)
     }
    
    func showHideLoginFields(show:Bool)
    {
       self.txtUserName.isHidden = show;
       self.txtPassword.isHidden = show;
       self.btnLogin.isHidden = show;
    }
    
    
    
    
    func fetchLoginFireBase(userName:String,password:String)
    {
      
        var fireBaseLogins = [Login]();
        //refLogins.observe(DataEventType.value, with: {(snapshot) in
        refLogins.queryOrdered(byChild: "UserName").queryEqual(toValue: userName).observe(DataEventType.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                self.bFound = false;
                //iterate through all the values
                for logins in snapshot.children.allObjects as! [DataSnapshot] {
                    //grabbing values
                    let loginObject = logins.value as? [String: AnyObject];
                    let UserName = loginObject?["UserName"];
                    let Password = loginObject?["Password"];
                    
                    let myLogin = Login();
                    myLogin.loginName = UserName as? String;
                    myLogin.Password = Password as? String;
                  
                    fireBaseLogins.append(myLogin);
                }
                
                for oLoginObject in fireBaseLogins {
                    let loginNameFB = oLoginObject.loginName!
                    let loginPwd = oLoginObject.Password!
                    if(loginNameFB == userName &&
                       loginPwd == password)
                    {
                       self.performSelector(onMainThread: #selector(AddAccountViewController.setRecordSuccessFlag(_:)), with: "success", waitUntilDone: false);
                    }
                    
                }
                
            } //if snapshot.children > 0 {
            else
            {
              
            }
            
        })
        
        
    }
    
    func setRecordSuccessFlag(_ bSuccess:String) {
        self.bFound = false;
        if(bSuccess == "success"){
            self.bFound = true;
            self.lblLoginError.textColor = UIColor.blue;
            self.lblLoginError.text = "Success!!";
            proceedToBankSetup();
            return;
        }
    }

    
    
    @IBAction func goToSignUpView(_ sender: Any) {
        let objSignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController;
        self.navigationController?.pushViewController(objSignUpViewController, animated: true);

    }
    
    

}

