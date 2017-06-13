//
//  AddExpenseViewController.swift
//  LevelMoney
//
//  Created by lionel on 6/9/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit
import Firebase

class AddExpenseViewController: UIViewController ,UITextFieldDelegate{

     var oAccounts = Accounts();
     var refExpenseItems: DatabaseReference!
    
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var txtsitePwdHint: UITextField!
    @IBOutlet weak var txtsiteUserName: UITextField!
    @IBOutlet weak var txtwebSiteAddress: UITextField!
    @IBOutlet weak var txtExpenseItem: UITextField!
    @IBOutlet weak var txtAverageExpenseAmount: UITextField!
    @IBOutlet weak var txtDueDate: UITextField!
    
    @IBOutlet weak var lblLoginError: UILabel!
    //var LoginName:String?
    
    
    @IBAction func goToExpenseItems(_ sender: Any) {
        //ViewExpenseDetailViewController
        let objViewExpenseDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewExpenseDetailViewController") as! ViewExpenseDetailViewController;
        objViewExpenseDetailViewController.oAccounts = self.oAccounts; //pass on the object from the main screen
        self.navigationController?.pushViewController(objViewExpenseDetailViewController, animated: true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refExpenseItems  = Database.database().reference().child("ExpenseItems")
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)));
    }

    
    func dismissKeyboard()
    {
        self.txtNotes.resignFirstResponder();
        self.txtsitePwdHint.resignFirstResponder();
        self.txtsiteUserName.resignFirstResponder();
        self.txtwebSiteAddress.resignFirstResponder();
        self.txtExpenseItem.resignFirstResponder();
        self.txtAverageExpenseAmount.resignFirstResponder();
        self.txtDueDate.resignFirstResponder();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtNotes.resignFirstResponder();
        self.txtsitePwdHint.resignFirstResponder();
        self.txtsiteUserName.resignFirstResponder();
        self.txtwebSiteAddress.resignFirstResponder();
        self.txtExpenseItem.resignFirstResponder();
        self.txtAverageExpenseAmount.resignFirstResponder();
        self.txtDueDate.resignFirstResponder();
        return true;
    }

    
    @IBAction func addExpenseItem(_ sender: Any) {
        self.lblLoginError.textColor = UIColor.black;
        self.lblLoginError.text = "";
        addExpenseItem();
    }
    
    func addExpenseItem()
    {
        
        self.lblLoginError.textColor = UIColor.black;
        self.lblLoginError.text = "";
        
        if(self.txtNotes.text != "" &&
        self.txtsitePwdHint.text != "" &&
        self.txtsiteUserName.text != "" &&
        self.txtwebSiteAddress.text != "" &&
        self.txtExpenseItem.text != "" &&
        self.txtAverageExpenseAmount.text != "" &&
        self.txtDueDate.text != "")
        {
            
            let key = refExpenseItems.childByAutoId().key
            let bank = ["id":key,
                        "ExpenseItem": self.txtExpenseItem.text! as String,
                        "AverageExpenseAmount": self.txtAverageExpenseAmount.text! as String,
                        "DueDate":self.txtDueDate.text! as String,
                        "webSiteAddress":self.txtwebSiteAddress.text! as String,
                        "siteUserName":self.txtsiteUserName.text! as String,
                        "sitePwdHint":self.txtsitePwdHint.text! as String,
                        "Notes":self.txtNotes.text! as String,
                        "LoginName":self.oAccounts.loginName! as String
                
            ]
            refExpenseItems.child(key).setValue(bank);
            
            self.lblLoginError.textColor = UIColor.blue;
            self.lblLoginError.text = "Expense Item Added";
            self.clearFields();
        }
        else
        {
            self.lblLoginError.textColor = UIColor.red;
            self.lblLoginError.text = "Need Data in all fields";
        }
    }
    
    func clearFields()
    {
            self.txtNotes.text = ""
            self.txtsitePwdHint.text = ""
            self.txtsiteUserName.text = ""
            self.txtwebSiteAddress.text = ""
            self.txtExpenseItem.text = ""
            self.txtAverageExpenseAmount.text = ""
            self.txtDueDate.text = ""
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
