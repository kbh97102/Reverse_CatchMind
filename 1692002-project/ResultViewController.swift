//
//  ResultViewController.swift
//  1692002-project
//
//  Created by mac016 on 2021/05/24.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var reslutLabel: UILabel!
    
    private var answer:String?
    private var result:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        answerLabel.text = answer
        reslutLabel.text = result
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("nextButtonCallBack"), object: nil)
        dismiss(animated: false, completion: nil)
    }
    @IBAction func retry(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    func test( answer: String, result: String){
        self.answer = answer
        self.result = result
    }
    
 
}
