//
//  DataModelController.swift
//  1692002-project
//
//  Created by mac006 on 2021/05/10.
//

import Foundation
import PencilKit
import os

struct DataModel: Codable{
    
    static let defaultDrawingNames: [String] = ["Notes"]
    
    static let canvasWidth: CGFloat = 768
    
    var drawings:[PKDrawing]=[]
    var signature = PKDrawing()
}

protocol DataModelControllerObserver {
    func dataModelChanged()
}

class DataModelController{
    
    var dataModel = DataModel()
    
    var observers = [DataModelControllerObserver]()
    
    var drawings: [PKDrawing]{
        get { dataModel.drawings}
        set { dataModel.drawings = newValue}
    }
    
    var signature: PKDrawing{
        get{dataModel.signature}
        set{dataModel.signature = newValue}
    }
    
    private let serializeationQueue = DispatchQueue(label: "SerializationQueue", qos: .background)
    
    init(){
        loadDataModel()
    }
    
    func updateDrawing(_ drawing: PKDrawing, at index: Int){
        dataModel.drawings[index] = drawing
        saveDataModel()
    }
    
    func saveDataModel(){
        let savingDataModel = dataModel
        let url = saveUrl
        serializeationQueue.async {
            do{
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(savingDataModel)
                try data.write(to: url)
            }catch{
                os_log("Failed save data %s", type: .error, error.localizedDescription)
            }
        }
    }
    
    func newDrawing(){
        let newDrawing = PKDrawing()
        dataModel.drawings.append(newDrawing)
        updateDrawing(newDrawing, at: dataModel.drawings.count-1)
    }
    
    private func didChange(){
        for observer in self.observers{
            observer.dataModelChanged()
        }
    }
    
    private func loadDataModel(){
        let url = saveUrl
        serializeationQueue.async {
            let dataModel: DataModel
            
            if FileManager.default.fileExists(atPath: url.path){
                do{
                    let decoder = PropertyListDecoder()
                    let data = try Data(contentsOf: url)
                    dataModel = try decoder.decode(DataModel.self, from: data)
                }catch{
                    os_log("Can't load data model %s", type: .error, error.localizedDescription)
                    dataModel = self.loadDefaultDrawings()
                }
            }else{
                dataModel = self.loadDefaultDrawings()
            }
            DispatchQueue.main.async {
                self.setLoadedDataModel(dataModel)
            }
        }
    }
    
    private func setLoadedDataModel(_ dataModel: DataModel){
        self.dataModel = dataModel
    }
    
    private func loadDefaultDrawings() -> DataModel{
        var testDataModel = DataModel()
        for sampleDataName in DataModel.defaultDrawingNames{
            guard let data = NSDataAsset(name: sampleDataName)?.data else {continue}
            if let drawing = try? PKDrawing(data: data){
                testDataModel.drawings.append(drawing)
            }
        }
        return testDataModel
    }
    
    private var saveUrl:URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths.first!
        return documentDirectory.appendingPathComponent("PencilKitDraw.data")
    }
}
