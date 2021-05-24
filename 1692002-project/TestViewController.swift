//
//  TestViewController.swift
//  1692002-project
//
//  Created by mac016 on 2021/05/17.
//

import UIKit
import PencilKit
import PhotosUI
import CoreML
import Vision

class TestViewController: UIViewController , PKCanvasViewDelegate, PKToolPickerObserver{

    @IBOutlet weak var questionLabel: UILabel!

    @IBOutlet weak var canvasView: PKCanvasView!
    

    private let toolPicker = PKToolPicker()
    private var request: VNCoreMLRequest?
    private var question: Question?
    private var answer: String = ""

    
    var drawing = PKDrawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPkCanvas()
        
        question = Question()
        request =  createCoreMLRequest(modelName: "SqueezeNet", modelExt: "mlmodelc", comletionHandler: imageClassificationHandler(request:error:))
        
        displayQuestion()
    }
    
    private func setUpPkCanvas(){

        canvasView.delegate = self
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true
        canvasView.drawingPolicy = .anyInput

        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)

        
        canvasView.tool = PKInkingTool(.pen, color: .blue, width: 20)
        canvasView.becomeFirstResponder()
    }
    
    @IBAction func SaveButton(_ sender: UIBarButtonItem) {
        let image = GetImage()
        if image != nil{
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: {success, fail in
                
            })
        }
    }
    
    @IBAction func SubmitButton(_ sender: UIBarButtonItem) {
        let image = GetImage()
        if image != nil{

            let handler = VNImageRequestHandler(ciImage : CIImage(image: image!)!)
            try! handler.perform([request!])
        }
        
        let alert = self.storyboard?.instantiateViewController(identifier: "ResultView") as! ResultViewController
        
        present(alert, animated: true, completion: nil)
    }

    private func GetImage() -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension TestViewController{
    func createCoreMLRequest(modelName :String, modelExt: String, comletionHandler : @escaping (VNRequest, Error?) -> Void) -> VNCoreMLRequest?{
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: modelExt) else{
            return nil
        }
        
        guard let vnCoreMLModel = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL)) else {
            return nil
        }
        
        return VNCoreMLRequest(model: vnCoreMLModel, completionHandler: comletionHandler)
    }
    
    func imageClassificationHandler(request: VNRequest, error:Error?){
        guard let results = request.results as? [VNClassificationObservation] else {
            return
        }
        
        if let topResult = results.first{
            //TODO Display Result
            
        }
    }
}

extension TestViewController{
    func displayQuestion(){
        answer = question!.getQuestion()
        questionLabel.text = answer
    }
}
