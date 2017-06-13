//
//  CreateProfileViewController.swift
//  LevelMoney
//
//  Created by lionel on 6/4/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit
import Firebase

class CreateProfileViewController: UIViewController,UITextFieldDelegate {

    
    //I crated these using the assistant editor
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPasswordVerify: UITextField!
    
    @IBOutlet weak var btnProceed: UIButton!
    
    var webServiceIPAdress:String = "";
    var oLogin = Login();
    var bSuccessfulRecordAdd:Bool! = false;
    
    var refLogins: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webServiceIPAdress = initilizeConnString();
        
        self.btnProceed.isEnabled = false;
        self.btnProceed.isHidden = true;

        //for dismissing the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)));
        
        refLogins  = Database.database().reference().child("LoginTable");

    }

    
    func dismissKeyboard()
    {
        self.txtUserName.resignFirstResponder();
        self.txtPassword.resignFirstResponder();
        self.txtPasswordVerify.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtUserName.resignFirstResponder();
        self.txtPassword.resignFirstResponder();
        self.txtPasswordVerify.resignFirstResponder();
        return true;
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goToBankSetup(_ sender: Any) {
        
        let objBankSetupViewController = self.storyboard?.instantiateViewController(withIdentifier: "BankSetupViewController") as! BankSetupViewController;
        
        if(self.txtUserName.text != "") {
            objBankSetupViewController.oAccounts.loginName = self.txtUserName.text!;
        self.navigationController?.pushViewController(objBankSetupViewController, animated: true);
        }

    }
    
    @IBAction func submitProfile(_ sender: Any) {
        
        if(self.txtUserName.text != "" &&
            self.txtPassword.text != "" &&
            self.txtPasswordVerify.text != "")
        {
           
            
            //make REST CALL to add Login Record
            oLogin.loginName = self.txtUserName.text;
            oLogin.Password = self.txtPassword.text;
           
            //GET WORKS
            //makeRESTCallGETCategories();
            
            self.lblMessage.textColor = UIColor.black;
            self.lblMessage.text = "";
            
            //old REST method
           // _ =  addLoginRecords(objLogin: oLogin);
            
            //firebase method
            addLoginRecordFireBase();
        }
        else{
            self.lblMessage.textColor = UIColor.red;
            self.lblMessage.text = "You are missing information!!";
            toggleProceedToBankSetupScreen(isOk: false);
        }
    }

    func initilizeConnString() -> String{
        let path: String = Bundle.main.path(forResource: "Info", ofType: "plist")!
        let nsDictionaryInfoPlist: NSDictionary = NSDictionary(contentsOfFile: path)!
        print(nsDictionaryInfoPlist["WebServiceIPAddress"]!);
        return nsDictionaryInfoPlist["WebServiceIPAddress"] as! String;  //casting
        
    }
    
    
    func getWEBAPIPrefix() -> String{
        let path: String = Bundle.main.path(forResource: "Info", ofType: "plist")!
        let nsDictionaryInfoPlist: NSDictionary = NSDictionary(contentsOfFile: path)!
        print(nsDictionaryInfoPlist["WEBAPIPrefix"]!);
        return nsDictionaryInfoPlist["WEBAPIPrefix"] as! String;  //casting
    }

    
    /*FIREBASE WAY */
    func addLoginRecordFireBase()
    {
        let key = refLogins.childByAutoId().key;
        let account = ["id":key,
                       "UserName": self.txtUserName.text! as String,
                       "Password": self.txtPassword.text! as String]
        refLogins.child(key).setValue(account);
        setRecordSuccessFlag("success");
    }
    
    
    
    
    /*old restful way  */
    func addLoginRecords(objLogin:Login) -> Bool {
        let bSuccess:Bool! = true;

        let WEBAPIPrefix = getWEBAPIPrefix();
        
        //we need a URL
        let postEndPoint: String = "http://" + webServiceIPAdress + WEBAPIPrefix + "addLoginRecord";
        let url = NSURL(string: postEndPoint)!;
        
        //need parameters for header
        let postParams: [String:AnyObject] = ["loginName": (oLogin.loginName)! as AnyObject,
                                              "Password": (oLogin.Password)! as AnyObject];
        
        //Make a request
        let request = NSMutableURLRequest(url:url as URL);

        
        //create a session
        let session = URLSession.shared;  //THE OBJECT WE ARE USING TO MAKE THE REST REQUEST
        
        request.httpMethod = "POST";
        
        //make the POST
        do
        {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: .prettyPrinted)
            print(postParams);
        }
        catch let error
        {
            print(error.localizedDescription);
        }
        
        //we have to define the content -type
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
           
            guard let realResponse = response as? HTTPURLResponse,
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return;
            }
            
            self.performSelector(onMainThread: #selector(CreateProfileViewController.setRecordSuccessFlag(_:)), with: "success", waitUntilDone: false);
        
        })
        task.resume() //let task

        return bSuccess!;
    }
    
    //this method for GET works****
    func makeRESTCallGETCategories() {
        let WEBAPIPrefix = getWEBAPIPrefix();
        let webServiceURL = "http://" + webServiceIPAdress + WEBAPIPrefix + "fetchCategories";
        print(webServiceURL);
        let postEndPoint: String = webServiceURL;
        //CREATE TASK USING DATA TASK WITH REQUEST*** - SWIFT 3.0
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration:config);
        let url = URL(string: postEndPoint)!;
        
        let task = session.dataTask(with: url,completionHandler: {
            (data,response,error) in
            
            if error != nil {
                print (error!.localizedDescription);
            }
            else
            {
                do
                {
                    //implement your logic here
                    guard let realResponse = response as? HTTPURLResponse,
                        realResponse.statusCode == 200 else {
                            print("Not a 200 response")
                            return;
                    }
                    if NSString(data:data!,encoding: String.Encoding.utf8.rawValue) != nil {
                        //parse the JSON to get the data
                        let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                        //update something on the main thread -- i can use this later for returning true or false from a method
                        //self.performSelector(onMainThread: #selector(EmployeeViewController.populateCategoryPicker(_:)), with: jsonDictionary, waitUntilDone: false);
                        print(jsonDictionary);
                    }
                }
                catch
                {
                    print("error in JSONSerialization");
                }
            }
            
        })
        task.resume();
    }
    
    func toggleProceedToBankSetupScreen(isOk:Bool)
    {
        if(isOk)
        {
            self.btnProceed.isEnabled = true;
            self.btnProceed.isHidden = false;
        }
        else
        {
            self.btnProceed.isEnabled = false;
            self.btnProceed.isHidden = true;
        }
    }
    
    func setRecordSuccessFlag(_ bSuccess:String) {
        
        if(bSuccess == "success"){
            self.bSuccessfulRecordAdd = true;
        }
        
        if(self.bSuccessfulRecordAdd)
        {
            self.lblMessage.textColor = UIColor.blue;
            self.lblMessage.text = "Success!!";
            toggleProceedToBankSetupScreen(isOk: true);
        }
        else{
            self.lblMessage.textColor = UIColor.red;
            self.lblMessage.text = "Could not add login record!!";
            toggleProceedToBankSetupScreen(isOk: false);
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
