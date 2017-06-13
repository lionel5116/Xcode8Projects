//
//  AddAccountViewController.swift
//  LevelMoney
//
//  Created by lionel jones on 6/6/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit
import Firebase

class AddAccountViewController: UIViewController,UITextFieldDelegate {

    var webServiceIPAdress:String = "";
    var oAccounts = Accounts();
    var oBank = Bank();   //when coming from pick bank's edit actions to add a bank to check if bank exists for current logged on user
    var oExistingMyAccountRecID:String?
    var oExistingAccountBalance:String?
    var bSuccessfulRecordAdd:Bool! = false;

    var refAccounts: DatabaseReference!
    var bFound:Bool?
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var txtLoginName: UITextField!
    @IBOutlet weak var txtBankName: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webServiceIPAdress = initilizeConnString();
        print("User Name passed from Pick Bank View  \(self.oAccounts.loginName!)");
        print("Bank Name passed from Pick Bank View  \(self.oBank.BankName!)");
        
        self.txtBankName.text = self.oBank.BankName!;   //from pick bank's tableview controller
        self.txtLoginName.text = self.oAccounts.loginName!;  //initilized at login screen
        
        //for dismissing the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)));
        
        refAccounts  = Database.database().reference().child("MyBankAccounts");
        
        //see if bank exists in your account table (MyBankAccounts table)
        checkIfBankRecordExits();
        
      
    }

    func dismissKeyboard()
    {
        self.txtLoginName.resignFirstResponder();
        self.txtBankName.resignFirstResponder();
        self.txtAmount.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtLoginName.resignFirstResponder();
        self.txtBankName.resignFirstResponder();
        self.txtAmount.resignFirstResponder();
        return true;
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

    
    @IBAction func addAccountRecord(_ sender: Any) {
      
        if(self.txtAmount.text != "" &&
           self.txtLoginName.text != "" &&
           self.txtBankName.text != "")
        {
            //_ = addBankRecord(); - OLD RESTUL SERVICE FROM HOME
            
            if(self.bSuccessfulRecordAdd)
            {
                //update record
                updateBankRecordFireBase();
            }
            else
            {
                addBankRecordFireBase() //add banks to firebase
            }
            
            
           
        }
    }
    
    
    /*FIREBASE*/
    
    func addBankRecordFireBase()
    {
        let key = refAccounts.childByAutoId().key;  //create a new key for the myAccounts Table (Your bank account)
        let account = ["id":key,
                       "Amount": self.txtAmount.text! as String,
                       "LoginName": self.txtLoginName.text! as String,
                       "BankName": self.txtBankName.text! as String
        ]
        refAccounts.child(key).setValue(account);
        
        self.lblMessage.textColor = UIColor.blue;
        self.lblMessage.text = "Success .. Record added!!";
    }
    
    func updateBankRecordFireBase()
    {
        
        let key = oExistingMyAccountRecID;  //id already exist
        let updateAccount = ["id":key!,
                       "Amount": self.txtAmount.text! as String,
                       "LoginName": self.txtLoginName.text! as String,
                       "BankName": self.txtBankName.text! as String]
        
        refAccounts.child(key!).setValue(updateAccount)
        self.lblMessage.textColor = UIColor.blue;
        self.lblMessage.text = "Success .. Record Updated!!";
       
    }
    
    func checkIfBankRecordExits()
    {
        fetchBankFireBase(mBankName: self.oBank.BankName!);
    }
    
    
    func fetchBankFireBase(mBankName:String)
    {
        //refAccounts  = Database.database().reference().child("MyBankAccounts");
        var fireBaseMyAccounts = [MyBankAccounts]();
        refAccounts.queryOrdered(byChild: "BankName").queryEqual(toValue: mBankName).observe(DataEventType.value, with: {(snapshot) in
            if snapshot.childrenCount > 0 {
                self.bFound = false;
                //iterate through all the values
                for myAccounts in snapshot.children.allObjects as! [DataSnapshot] {
                    //grabbing values
                    let myAcctObject = myAccounts.value as? [String: AnyObject];
                    let id = myAcctObject?["id"];  
                    let BankName = myAcctObject?["BankName"];
                    let Amount = myAcctObject?["Amount"];
                    let LoginName = myAcctObject?["LoginName"];
                    
                    var myAccount = MyBankAccounts();  //i use this object for fetching my accounts and balances on another view (MyAccountsViewController)
                    myAccount.id = id as? String;
                    myAccount.BankName = BankName as? String;
                    myAccount.Amount = Amount as? Double;
                    myAccount.LoginName = LoginName as? String;
                    
                    self.oExistingMyAccountRecID = myAccount.id;  //if the bank exists, show id on label
                    if (Amount != nil) {
                        self.oExistingAccountBalance = (Amount! as! String)
                        print(Amount!);
                    }
                  
                    
                   
                    fireBaseMyAccounts.append(myAccount);
                }
                
                for oAcctObject in fireBaseMyAccounts {
                    //let loginNameFB = oAcctObject.LoginName!
                    let BankName = oAcctObject.BankName!
                    if(BankName == mBankName)
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
        
        if(bSuccess == "success"){
            self.bSuccessfulRecordAdd = true;
            self.lblMessage.text = "You have an account: \(String(describing: oExistingMyAccountRecID!))";
            self.txtAmount.text = String(describing: self.oExistingAccountBalance!);
        }
        
        if(self.bSuccessfulRecordAdd)
        {
            self.lblMessage.textColor = UIColor.blue;
            //self.lblMessage.text = "Success!!";
        }
        else{
            self.lblMessage.textColor = UIColor.red;
            self.lblMessage.text = "Could not add bank record!!";
        }
        
    }

    
     /*FIREBASE*/
    
    
    
    /*OLD RESTFUL SERVICE WAY--WE ARE NOW USING FIREBASE */
    func addBankRecord() -> Bool {
        let bSuccess:Bool! = true;
        
        let WEBAPIPrefix = getWEBAPIPrefix();
        
        //we need a URL
        let postEndPoint: String = "http://" + webServiceIPAdress + WEBAPIPrefix + "addAccountRecord";
        let url = NSURL(string: postEndPoint)!;
        
        //need parameters for header
        let postParams: [String:AnyObject] = ["BankName": (self.oAccounts.BankName)! as AnyObject,
                                              "LoginName": (self.oAccounts.loginName)! as AnyObject,
                                              "Amount": (self.txtAmount.text)! as AnyObject];
        
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
            
            self.performSelector(onMainThread: #selector(AddAccountViewController.setRecordSuccessFlag(_:)), with: "success", waitUntilDone: false);
            
        })
        task.resume() //let task
        
        return bSuccess!;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
