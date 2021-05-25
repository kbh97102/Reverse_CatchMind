//
//  Question.swift
//  1692002-project
//
//  Created by mac016 on 2021/05/24.
//

import Foundation


class Question {
    

    private var list: [String]
    private var index = 0
    
    init() {
        list = ["apple", "pin"]
    }
    
    func getQuestion()->String{
        let question = list[index % list.count]
        index += 1
        return question
    }
    
}
