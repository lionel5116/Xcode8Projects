//
//  MyAccountsViewController.swift
//  LevelMoney
//
//  Created by lionel on 6/6/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit
import Firebase

class MyAccountsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var refAccounts: DatabaseReference!
    
    //we will not be using this anymore (we are using firebase)
    var webServiceIPAdress:String = "";
    
    
    var oAccounts = Accounts();

    @IBOutlet weak var tvAccounts: UITableView!
    @IBOutlet weak var lblMyAccounts: UILabel!
    
    
    @IBAction func goToMyAccounts(_ sender: Any) {
        //fetchBanksLevelMoney();
        //we are going to use FIRBASE
        fetchMyAccountsFireBase();
        
    }
    
    //WE WILL NOT BE USING BELOW (THIS IS THE OLD REST SERVICE CALL FROM MY HOME)
    var arrBankLevelMoney = [
        BankLevelMoney(BankName:"",BankType: "",completed: false, lastCompleted: nil,Amount:0)
    ];
    
   
     var arrMyBankAccounts = [
        MyBankAccounts(BankName:"",Amount:0,LoginName:"",id:"")
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webServiceIPAdress = initilizeConnString();
        print("User Name passed from Pick Banks screen  \(self.oAccounts.loginName!)");
        refAccounts  = Database.database().reference().child("MyBankAccounts")
        fetchMyAccountsFireBase();
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
        
        //FROM FIREBASE
        return arrMyBankAccounts.count;
    }
    
    /*required for UITableViewDelegate */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        
        
        //var currentBank: BankLevelMoney!;
        //currentBank = arrBankLevelMoney[indexPath.row];
       
        
        var currentAccount: MyBankAccounts!;
        currentAccount = arrMyBankAccounts[indexPath.row];
        
        //use the name property to set the value of the cell
        cell.textLabel?.text = currentAccount.BankName! +   " Balance: \(currentAccount.Amount!)";
               
        //set cell to transparent
        cell.backgroundColor = UIColor.clear;
        return cell;
        
    }
    
    
    
    /*FIREBASE*/
    
    func fetchMyAccountsFireBase()
    {
        //refAccounts.observe(DataEventType.value, with: {(snapshot) in  -- this would be to pull all accounts
        refAccounts.queryOrdered(byChild: "LoginName").queryEqual(toValue: oAccounts.loginName).observe(DataEventType.value, with: {(snapshot) in
            //if the reference has some values
            if snapshot.childrenCount > 0 {
                
                self.arrMyBankAccounts.removeAll();
                var ttlAccountBalances: Double! = 0;
                
                //iterate through all the values
                for banks in snapshot.children.allObjects as! [DataSnapshot] {
                    //grabbing values
                    let bankObject = banks.value as? [String: AnyObject];
                    let BankName =  bankObject?["BankName"];
                    let Amount =  bankObject?["Amount"];
                    let LoginName = bankObject?["LoginName"];
                    let id = bankObject?["id"];
                    
                    //creating bank object with model and fetched values
                    let Account = MyBankAccounts(BankName: (BankName as! String), Amount: (Amount as! NSString).doubleValue, LoginName: (LoginName as! String),id:(id as! String));
                    
                    self.arrMyBankAccounts.append(Account)
                    ttlAccountBalances = ttlAccountBalances + Account.Amount!;
                }
                
                //reload the tableview's data
                self.tvAccounts.reloadData();
                self.lblMyAccounts.textColor = UIColor.blue;
                self.lblMyAccounts.text = "Total Account Balances: \(String(format: "$%.02f", ttlAccountBalances))";
                

                
            } //if snapshot.children > 0 {
            
        })
    }

    
    
    
    
    /*FIREBASE END*/
    
    
    
    
    
    func fetchBanksLevelMoney() {
        let WEBAPIPrefix = getWEBAPIPrefix();
        let webServiceURL = "http://" + webServiceIPAdress + WEBAPIPrefix + "fetchBanksLevelMoneyMine/" + oAccounts.loginName!
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
                        self.performSelector(onMainThread: #selector(MyAccountsViewController.populateBankTableView(_:)), with: jsonDictionary, waitUntilDone: false);
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
        
        arrBankLevelMoney.removeAll();
        
        var ttlAccountBalances: Double! = 0;
        
        for item in jsonDic as! [NSDictionary] {
            let oLevelMoney = BankLevelMoney(BankName:"\(item["BankName"]!)",BankType: "\(item["BankType"]!)",completed: false, lastCompleted:nil,Amount:(item["Amount"]! as! Double))
            arrBankLevelMoney.append(oLevelMoney);
            ttlAccountBalances = ttlAccountBalances + oLevelMoney.Amount!;
        }
        
        //rebind table
        self.tvAccounts.reloadData();
        print(ttlAccountBalances);
        self.lblMyAccounts.textColor = UIColor.blue;
        self.lblMyAccounts.text = "Total Account Balances: \(String(format: "$%.02f", ttlAccountBalances))";
        
    }
 

}
