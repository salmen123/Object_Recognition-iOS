//
//  ViewController.swift
//  Object Recognition
//
//  Created by Med Salmen Saadi on 5/13/18.
//  Copyright © 2018 Med Salmen Saadi. All rights reserved.
//

import UIKit

import CoreML
import Vision

import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var iv_Object: UIImageView!
    @IBOutlet weak var tv_ObjectDesc: UITextView!
    
    var imagePicker:UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker=UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func bu_TakePicture(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        iv_Object.image=info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        
        pictureIdentifyML(image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!)
    }
    
    func pictureIdentifyML(image:UIImage) {
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Cannot load ML model")
        }
        
        let request = VNCoreMLRequest(model: model) {
            [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let firstResult = results.first else {
                    fatalError("cannot get result from VNCoreMLRequest")
            }
            DispatchQueue.main.async {
                self?.tv_ObjectDesc.text = "confidence = \(Int(firstResult.confidence * 100))%, \n identifire \((firstResult.identifier))"
                
                //Text To Speech
                let utTerance = AVSpeechUtterance(string: (self?.tv_ObjectDesc.text)!)
                utTerance.voice = AVSpeechSynthesisVoice(language: "en-gb")
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utTerance)
            }
        }
        guard let ciImage = CIImage(image: image) else {
            fatalError("cannot convert to CIImage")
        }
        
        let imageHandler = VNImageRequestHandler(ciImage:ciImage)
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageHandler.perform([request])
            }
            catch {
            print("Error \(error)")
            }
        }
    }
}

