//
//  SignUpViewController.swift
//  LevelMoney
//
//  Created by lionel on 6/3/17.
//  Copyright © 2017 lionel. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goToCreateProfile(_ sender: Any) {
        let objCreateProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateProfileViewController") as! CreateProfileViewController;
        self.navigationController?.pushViewController(objCreateProfileViewController, animated: true);
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
