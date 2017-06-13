//
//  ListOfAccountsViewController.swift
//  LevelMoney
//
//  Created by lionel jones on 6/6/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit

class ListOfAccountsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

   
    
    var webServiceIPAdress:String = "";
    var oAccounts = Accounts();

   
    @IBOutlet weak var myTableView: UITableView!
    @IBAction func getYourListOfAccounts(_ sender: Any) {
        fetchAccountsLevelMoney();
    }
    
    /*
    var arrAccountDetails = [
        AccountDetails(acctEntryDate:nil, BankName:"", Amount:0, loginName:"")
    ];
 
    */
    
    /*
    var arrAccountDetails = [
        AccountDetails(acctEntryDate:nil, BankName:"Test Bank", Amount:25000, loginName:"Lionel5116"),
        AccountDetails(acctEntryDate:nil, BankName:"Wells Fargo", Amount:750000, loginName:"CarlMooton")
    ];
 */
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webServiceIPAdress = initilizeConnString();
        print("User Name passed from Pick Banks screen  \(self.oAccounts.loginName!)");    }

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
        //print(arrAccountDetails.count);
        //return arrAccountDetails.count;
        return 0;
    }
    
    /*required for UITableViewDelegate */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        /*
        //question structure, not a static string for our row data
        var currentAccount: AccountDetails!;
        currentAccount = arrAccountDetails[indexPath.row];
        //use the name property to set the value of the cell
        print(currentAccount.BankName!);
        cell.textLabel?.text = currentAccount.BankName;
        
        //check for completion
        
        if currentBank.completed {
            cell.textLabel?.textColor = UIColor.lightGray
            cell.accessoryType = .checkmark
        }
        else
        {
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = .none
        }
       */
        
        cell.textLabel?.textColor = UIColor.black
        cell.accessoryType = .none
        
        //set cell to transparent
        cell.backgroundColor = UIColor.clear;
        return cell;

               
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }

    func fetchAccountsLevelMoney() {
        //http://73.166.158.122//SandboxWEBAPI/api/onboarding/fetchAccountsLevelMoney/lionel5116
        
        let WEBAPIPrefix = getWEBAPIPrefix();
        let webServiceURL = "http://" + webServiceIPAdress + WEBAPIPrefix + "fetchAccountsLevelMoney/" + oAccounts.loginName!;
        
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
                        self.performSelector(onMainThread: #selector(ListOfAccountsViewController.populateListOfAccounts(_:)), with: jsonDictionary, waitUntilDone: false);
                        //print(jsonDictionary);
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
    
    func populateListOfAccounts(_ jsonDic:AnyObject){
        
        /*
        //clear the array
        var arrAccountDetails = [
            AccountDetails(acctEntryDate:nil, BankName:"", Amount:0, loginName:"")
        ];
        
        
        for item in jsonDic as! [NSDictionary] {
           /* let oAccountDetail = AccountDetails(BankName:"\(item["BankName"]!)")*/
            
let oAccountDetail = AccountDetails(acctEntryDate:nil,BankName:"\(item["BankName"]!)",Amount:0.00,loginName:"")
            arrAccountDetails.append(oAccountDetail);
        }
        
        //rebind table
        self.myTableView.reloadData();
 */
        
    }


}
