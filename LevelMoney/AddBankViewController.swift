//
//  AddBankViewController.swift
//  LevelMoney
//
//  Created by lionel on 6/9/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit
import Firebase

class AddBankViewController: UIViewController,UITableViewDataSource,UITableViewDelegate ,UITextFieldDelegate{

    var oAccounts = Accounts();
    
    var refBanks: DatabaseReference!
    
    @IBOutlet weak var txtBankName: UITextField!
    @IBOutlet weak var txtBankType: UITextField!
    @IBOutlet weak var tvBanks: UITableView!
    
    @IBAction func addNewBank(_ sender: Any) {
        if (self.txtBankName.text != "" &&
            self.txtBankType.text != "")
        {
            addBank();
            fetchBanksFireBase();
        }
    }
    
    @IBAction func fetchBanks(_ sender: Any) {
        fetchBanksFireBase()
    }
    
    var arrBanks = [
        Bank(BankName:"",BankType:"",BankBalance:0,id:"")
    ];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tvBanks.delegate = self;
        self.tvBanks.dataSource = self;
        
        //for dismissing the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)));
        //FirebaseApp.configure();  //do at the appDelegate level
        refBanks  = Database.database().reference().child("Bank");
        fetchBanksFireBase();
    }

    
    func dismissKeyboard()
    {
        self.txtBankName.resignFirstResponder();
        self.txtBankType.resignFirstResponder();
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtBankName.resignFirstResponder();
        self.txtBankType.resignFirstResponder();
        return true;
    }
    
    /*TABLEVIEW DELEGATE METHODS  */
    /*The "2" below are the minimum required for the  UITableViewDelegate protocol */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrBanks.count;
    }
    
    /*required for UITableViewDelegate */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        
        //question structure, not a static string for our row data
        var currentBank: Bank!;
        currentBank = arrBanks[indexPath.row];
        
        //use the name property to set the value of the cell
        cell.textLabel?.text = currentBank.BankName!;
        
        //set cell to transparent
        cell.backgroundColor = UIColor.clear;
        return cell;
        
    }
    
    func addBank()
    {
        let key = refBanks.childByAutoId().key
        let bank = ["id":key,
                    "BankName": self.txtBankName.text! as String,
                    "BankType": self.txtBankType.text! as String,
                    "BankBalance":"0" as String
        ]
        refBanks.child(key).setValue(bank);
        fetchBanksFireBase();
        
    }

    
    func fetchBanksFireBase()
    {
        refBanks.observe(DataEventType.value, with: {(snapshot) in
            
            //if the reference has some values
            if snapshot.childrenCount > 0 {
                
                self.arrBanks.removeAll();
                
                //iterate through all the values
                for banks in snapshot.children.allObjects as! [DataSnapshot] {
                    //grabbing values
                    let bankObject = banks.value as? [String: AnyObject];
                    let bankName =  bankObject?["BankName"];
                    let bankType =  bankObject?["BankType"];
                    let bankBalance = bankObject?["BankBalance"];
                    let bankId = bankObject?["id"];
                    
                    //creating bank object with model and fetched values
                    let bank = Bank(BankName: (bankName as! String), BankType: (bankType as! String), BankBalance: (bankBalance as! NSString).doubleValue,id:(bankId as! String));
                    
                    self.arrBanks.append(bank)
                }
                
                //reload the tableview's data
                self.tvBanks.reloadData();
                
            } //if snapshot.children > 0 {
            
        })
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
