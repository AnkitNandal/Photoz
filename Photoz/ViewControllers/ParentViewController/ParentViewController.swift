//
//  ParentViewController.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/08/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import UIKit

class ParentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func showAlert(with text:String?) {
        guard let alertText = text else {return}
        let alertController = UIAlertController(title: "Alert", message: alertText, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
        }
        alertController.addAction(action1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
}
