//
//  BankSetupViewController.swift
//  LevelMoney
//
//  Created by lionel jones on 6/5/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit

class BankSetupViewController: UIViewController {
    var oAccounts = Accounts();
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goToPickBank(_ sender: Any) {
        let objPickBankViewController = self.storyboard?.instantiateViewController(withIdentifier: "PickBankViewController") as! PickBankViewController;
        objPickBankViewController.oAccounts = self.oAccounts; //pass on the object from the main screen
        self.navigationController?.pushViewController(objPickBankViewController, animated: true);
    }
   

    @IBAction func addNewBanks(_ sender: Any) {
        let objAddBankViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddBankViewController") as! AddBankViewController;
        objAddBankViewController.oAccounts = self.oAccounts; //pass on the object from the main screen
        self.navigationController?.pushViewController(objAddBankViewController, animated: true);

    }
    
    
    @IBAction func goToMonthlyExpenseView(_ sender: Any) {
        //AddExpenseViewController
        let objAddExpenseViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddExpenseViewController") as! AddExpenseViewController;
        objAddExpenseViewController.oAccounts = self.oAccounts; //pass on the object from the main screen
        self.navigationController?.pushViewController(objAddExpenseViewController, animated: true);
        
    }
    
}
