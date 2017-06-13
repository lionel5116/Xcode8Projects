//
//  ExpDetailExtendedViewController.swift
//  LevelMoney
//
//  Created by lionel on 6/9/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit
import Firebase

class ExpDetailExtendedViewController: UIViewController  ,UITextFieldDelegate{

    var refExpenseItems: DatabaseReference!
    var ExpenseItem:String?;
    
    var oExpense = Expense()
    
    @IBOutlet weak var txtExpenseItem: UITextField!
    @IBOutlet weak var txtAverageExpenseAmount: UITextField!
    @IBOutlet weak var txtDueDate: UITextField!
    @IBOutlet weak var txtwebSiteAddress: UITextField!
    @IBOutlet weak var txtsiteUserName: UITextField!
    @IBOutlet weak var txtsitePwdHint: UITextField!
    @IBOutlet weak var txtNotes: UITextView!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBAction func updateExpenseRecord(_ sender: Any) {
        self.lblMessage.textColor = UIColor.black;
        self.lblMessage.text = "";
        updateExpenseRecordFireBase();

    }
    
   
    
    var arrExpenseItems = [
        MonthlyExpense(ExpenseItem:"",AverageExpenseAmount:0,DueDate:"",webSiteAddress:"",siteUserName:"",sitePwdHint:"",Notes:"",LoginName:"", id: "")
    ];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refExpenseItems  = Database.database().reference().child("ExpenseItems")
        //fetchExpenseItemsFireBase();
        fieldItemsFromViewController()
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

    
    func fieldItemsFromViewController()
    {
        self.txtNotes.text = oExpense.Notes;
        self.txtsitePwdHint.text = oExpense.sitePwdHint;
        self.txtsiteUserName.text = oExpense.siteUserName;
        self.txtwebSiteAddress.text = oExpense.webSiteAddress;
        self.txtExpenseItem.text = oExpense.ExpenseItem;
        self.txtAverageExpenseAmount.text = String(describing: oExpense.AverageExpenseAmount!)
        self.txtDueDate.text = oExpense.DueDate;
        self.lblMessage.text = oExpense.id!;
    }
    
    func updateExpenseRecordFireBase()
    {
        
        let key = oExpense.id;
        
        let updateExpense = ["ExpenseItem":self.txtExpenseItem.text!,"AverageExpenseAmount":self.txtAverageExpenseAmount.text!,"DueDate":self.txtDueDate.text!,"webSiteAddress":self.txtwebSiteAddress.text!,"siteUserName":self.txtsiteUserName.text!,"sitePwdHint":self.txtsitePwdHint.text!,"Notes":self.txtNotes.text!,"LoginName":oExpense.LoginName!,"id":oExpense.id!]
            refExpenseItems.child(key!).setValue(updateExpense)
        
        
        self.lblMessage.textColor = UIColor.blue;
        self.lblMessage.text = "Updated Expense Record..";
    }
    
    
    func fetchExpenseItemsFireBase()
    {
        //refAccounts.queryOrdered(byChild: "LoginName").queryEqual(toValue: oAccounts.loginName).observe(DataEventType.value, with: {(snapshot) in
        refExpenseItems.queryOrdered(byChild: "ExpenseItem").queryEqual(toValue:ExpenseItem).observe(DataEventType.value, with: {(snapshot) in
            //if the reference has some values
            if snapshot.childrenCount > 0 {
                
                self.arrExpenseItems.removeAll();
                
                //iterate through all the values
                for expense in snapshot.children.allObjects as! [DataSnapshot] {
                    //grabbing values
                    let expenseObject = expense.value as? [String: AnyObject];
                    let ExpenseItem =  expenseObject?["ExpenseItem"];
                    let AverageExpenseAmount =  expenseObject?["AverageExpenseAmount"];
                    let DueDate =  expenseObject?["DueDate"];
                    let webSiteAddress =  expenseObject?["webSiteAddress"];
                    let siteUserName =  expenseObject?["siteUserName"];
                    let sitePwdHint =  expenseObject?["sitePwdHint"];
                    let Notes =  expenseObject?["Notes"];
                    let LoginName =  expenseObject?["LoginName"];
                    let id = expenseObject?["id"];
                    
                    //creating bank object with model and fetched values
                    let expenseItem = MonthlyExpense(ExpenseItem:(ExpenseItem as! String),AverageExpenseAmount: (AverageExpenseAmount as! NSString).doubleValue,DueDate:(DueDate as! String),webSiteAddress:(webSiteAddress as! String),siteUserName:(siteUserName as! String),sitePwdHint:(sitePwdHint as! String),Notes:(Notes as! String),LoginName:(LoginName as! String), id: (id as! String));
                    self.arrExpenseItems.append(expenseItem)
                    
                    self.txtNotes.text = expenseItem.Notes;
                    self.txtsitePwdHint.text = expenseItem.sitePwdHint;
                    self.txtsiteUserName.text = expenseItem.siteUserName;
                    self.txtwebSiteAddress.text = expenseItem.webSiteAddress;
                    self.txtExpenseItem.text = expenseItem.ExpenseItem;
                    self.txtAverageExpenseAmount.text = (AverageExpenseAmount as! NSString as String)
                    self.txtDueDate.text = expenseItem.DueDate;
                }
                
            } //if snapshot.children > 0 {
            
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
  
}
