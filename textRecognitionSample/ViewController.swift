//
//  ViewController.swift
//  textRecognitionSample
//
//  Created by Denis Goloborodko on 29.10.21.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     }

    @IBAction func ScanButtonTapped(_ sender: Any) {
        let cameraViewController = CameraViewController()
        
        cameraViewController.delegate = self
        
        present(cameraViewController, animated: true)
    }
    
}

extension ViewController: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        let recognizedText = recognizeText(from: extractImages(from: scan))
        
        print(recognizedText)
        self.textView.text = recognizedText
        
        self.dismiss(animated: true) {
            
        }
    }
    
    private func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
        var extractedImages: [CGImage] = []
        
        for index in 0..<scan.pageCount {
            let extractedImage = scan.imageOfPage(at: index)
            guard let cgImage = extractedImage.cgImage else { continue }
            
            extractedImages.append(cgImage)
        }
        
        return extractedImages
    }
    
    private func recognizeText(from images: [CGImage]) -> String {
        var recognizedText = ""
        
        let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {
                print(String(describing: error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("Could not retrieve text observations")
                return
            }
            
            let maximumRecognitionCandidates = 1
            
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else {
                    print("No recognition candidates")
                    continue
                }
                
                recognizedText += "\(candidate.string)\n"
            }
        }
        
        recognizeTextRequest.recognitionLevel = .accurate
        
        for image in images {
            let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
            
            try? requestHandler.perform([recognizeTextRequest])
        }
        
        return recognizedText
    }
    
}
