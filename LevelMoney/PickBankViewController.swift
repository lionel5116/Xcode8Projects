//
//  PickBankViewController.swift
//  LevelMoney
//
//  Created by lionel jones on 6/5/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit
import Firebase


class PickBankViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var webServiceIPAdress:String = "";
    var oAccounts = Accounts();
    var oBank = Bank();
   
    @IBOutlet weak var lblSelectABank: UILabel!
    
    var refBanks: DatabaseReference!
    
    //you needed a pointer to reference the tableview in code
    @IBOutlet weak var tvBankLevelMoney: UITableView!
    
    @IBAction func goToMListOfAccounts(_ sender: Any) {
        goToMyAccounts();
    }
    
    @IBAction func fetchBanks(_ sender: Any) {
        //fetchBanksLevelMoney();
        fetchBanksFireBase();
        lblSelectABank.textColor = UIColor.red;
        lblSelectABank.text = "Select a Bank and Swipe to Add/Edit Balances";
    }
    
    //NOT BEING USED - OLD RESTFUL SERVICE
    var arrBankLevelMoney = [
        BankLevelMoney(BankName:"",BankType: "",completed: false, lastCompleted: nil,Amount:0)
    ];
    
    //USING FIREBASE
    var arrBanks = [
        Bank(BankName:"",BankType:"",BankBalance:0,id:"")
    ];

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webServiceIPAdress = initilizeConnString();
        print("User Name passed from login screen  \(self.oAccounts.loginName!)");
        refBanks  = Database.database().reference().child("Bank");
        lblSelectABank.text = "";
        
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    
    /*TABLEVIEW DELEGATE METHODS  */
    /*The "2" below are the minimum required for the  UITableViewDelegate protocol */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return arrBankLevelMoney.count;
        
        //firebase
        return arrBanks.count;
        
    }
    
    /*required for UITableViewDelegate */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        
     
        //var currentBank: BankLevelMoney!;
        //currentBank = arrBankLevelMoney[indexPath.row];
        
        var currentBank: Bank!;
        currentBank = arrBanks[indexPath.row];
        
        
        //use the name property to set the value of the cell
        cell.textLabel?.text = currentBank.BankName;
        
              //set cell to transparent
        cell.backgroundColor = UIColor.clear;
        return cell;
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    //for adding swipe behavior
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let AddAccountAction = UITableViewRowAction(style: .default, title: "Add/Update Acct", handler:
        {
            //closure parameters
            action,indexPath in
            
            
            print("Open up Add Accounts screen for \(self.arrBanks[indexPath.row])" );
            
            tableView.reloadData();
            //tell the table view it's done editing
            tableView.isEditing = false;
            
            
            
            self.oBank.BankName = self.arrBanks[indexPath.row].BankName;
            self.oBank.BankType = self.arrBanks[indexPath.row].BankType;
            self.oBank.BankBalance = self.arrBanks[indexPath.row].BankBalance;
            self.oBank.id = self.arrBanks[indexPath.row].id;
            self.goToAddAccountsScreen(objAccounts: self.oAccounts,objBank:self.oBank);
            
        });
        
        //let actions = [likeAction,DislikeAction,CommentsAction]
        let actions = [AddAccountAction]
        return actions;
        
    }
    
    func goToAddAccountsScreen(objAccounts:Accounts,objBank:Bank){
        
        let objAddAccountViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddAccountViewController") as! AddAccountViewController;
        
        objAddAccountViewController.oAccounts = objAccounts;
        objAddAccountViewController.oBank = objBank;
        self.navigationController?.pushViewController(objAddAccountViewController, animated: true);
    }
    
    
    
    func goToMyAccounts()
    {
        let objMyAccountsViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyAccountsViewController") as! MyAccountsViewController;
        objMyAccountsViewController.oAccounts = self.oAccounts;
        self.navigationController?.pushViewController(objMyAccountsViewController, animated: true);
    
    }
    
    
    /*FIREBASE*/
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
                self.tvBankLevelMoney.reloadData();
                
            } //if snapshot.children > 0 {
            
        })
    }
    /*FIREBASE*/
    
    
    
    //this method for GET works****  OLD DATA FETCHING USING REST CALL TO MY SERVICE AT HOME
    func fetchBanksLevelMoney() {
        //http://73.166.158.122//SandboxWEBAPI/api/onboarding/fetchBanksLevelMoney
        
        let WEBAPIPrefix = getWEBAPIPrefix();
        let webServiceURL = "http://" + webServiceIPAdress + WEBAPIPrefix + "fetchBanksLevelMoney";
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
                        self.performSelector(onMainThread: #selector(PickBankViewController.populateBankTableView(_:)), with: jsonDictionary, waitUntilDone: false);
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
    
    func populateBankTableView(_ jsonDic:AnyObject){
        
        //clear the array
        arrBankLevelMoney = [
            BankLevelMoney(BankName:"",BankType: "",completed: false, lastCompleted: nil,Amount:0)
        ];

        
        for item in jsonDic as! [NSDictionary] {
            let oLevelMoney = BankLevelMoney(BankName:"\(item["BankName"]!)",BankType: "\(item["BankType"]!)",completed: false, lastCompleted:nil,Amount:0)
            arrBankLevelMoney.append(oLevelMoney);
        }
        
        //rebind table
        self.tvBankLevelMoney.reloadData();
        
    }

    
}
