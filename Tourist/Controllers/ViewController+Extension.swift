//
//  ViewController+Extension.swift
//  Tourist
//
//  Created by Ismail on 03/04/2021.
//

import Foundation
import UIKit

extension UIViewController{
    
    func showErrorAlert(message: String){
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
