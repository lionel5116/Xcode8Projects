//
//  ViewExpenseDetailViewController.swift
//  LevelMoney
//
//  Created by lionel on 6/9/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit
import Firebase

class ViewExpenseDetailViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate {

    var refExpenseItems: DatabaseReference!
    
     var oAccounts = Accounts();
     var oExpense = Expense();
    
    var arrExpenseItems = [
        MonthlyExpense(ExpenseItem:"",AverageExpenseAmount:0,DueDate:"",webSiteAddress:"",siteUserName:"",sitePwdHint:"",Notes:"",LoginName:"",id:"")
    ];
    
    @IBOutlet weak var tvExpenseItems: UITableView!
    @IBAction func getExpenseItems(_ sender: Any) {
        fetchExpenseItemsFireBase();
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       refExpenseItems  = Database.database().reference().child("ExpenseItems")
        self.tvExpenseItems.dataSource = self;
        self.tvExpenseItems.delegate = self;
    }

    
    /*TABLEVIEW DELEGATE METHODS  */
    /*The "2" below are the minimum required for the  UITableViewDelegate protocol */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrExpenseItems.count;
        
    }
    
    /*required for UITableViewDelegate */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
    
        
        var currentExpense: MonthlyExpense!;
        currentExpense = arrExpenseItems[indexPath.row];
        
        
        //use the name property to set the value of the cell
        cell.textLabel?.text = currentExpense.ExpenseItem;
        
        //set cell to transparent
        cell.backgroundColor = UIColor.clear;
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    //for adding swipe behavior
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let AddAccountAction = UITableViewRowAction(style: .default, title: "View Detail", handler:
        {
            //closure parameters
            action,indexPath in
            
                   
            tableView.reloadData();
            //tell the table view it's done editing
            tableView.isEditing = false;
            
            self.oExpense.ExpenseItem = self.arrExpenseItems[indexPath.row].ExpenseItem;
            self.oExpense.AverageExpenseAmount = self.arrExpenseItems[indexPath.row].AverageExpenseAmount;
            self.oExpense.DueDate = self.arrExpenseItems[indexPath.row].DueDate;
            self.oExpense.webSiteAddress = self.arrExpenseItems[indexPath.row].webSiteAddress;
            self.oExpense.siteUserName = self.arrExpenseItems[indexPath.row].siteUserName;
            self.oExpense.sitePwdHint = self.arrExpenseItems[indexPath.row].sitePwdHint;
            self.oExpense.Notes = self.arrExpenseItems[indexPath.row].Notes;
            self.oExpense.LoginName = self.arrExpenseItems[indexPath.row].LoginName;
            self.oExpense.id = self.arrExpenseItems[indexPath.row].id;
            
        
            let objExpDetailExtendedViewController = self.storyboard?.instantiateViewController(withIdentifier: "ExpDetailExtendedViewController") as! ExpDetailExtendedViewController;
            objExpDetailExtendedViewController.oExpense = self.oExpense //pass on the object from the main screen
            self.navigationController?.pushViewController(objExpDetailExtendedViewController, animated: true);
        });
        
        //let actions = [likeAction,DislikeAction,CommentsAction]
        let actions = [AddAccountAction]
        return actions;
        
    }
    
    func fetchExpenseItemsFireBase()
    {
        refExpenseItems.observe(DataEventType.value, with: {(snapshot) in
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
                    let expenseItem = MonthlyExpense(ExpenseItem:(ExpenseItem as! String),AverageExpenseAmount: (AverageExpenseAmount as! NSString).doubleValue,DueDate:(DueDate as! String),webSiteAddress:(webSiteAddress as! String),siteUserName:(siteUserName as! String),sitePwdHint:(sitePwdHint as! String),Notes:(Notes as! String),LoginName:(LoginName as! String),id:(id as! String));
                    self.arrExpenseItems.append(expenseItem)
                }
                
                //reload the tableview's data
                self.tvExpenseItems.reloadData();
                
            } //if snapshot.children > 0 {
            
        })
    }

    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
