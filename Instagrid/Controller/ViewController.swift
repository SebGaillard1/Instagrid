//
//  ViewController.swift
//  Instagrid
//
//  Created by Sebastien Gaillard on 01/05/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gridView: UIView!
    
    var button: UIButton?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonImageGridPressed(_ sender: UIButton) {
        
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        pickerController.allowsEditing = true

        self.present(pickerController, animated: true, completion: nil)
        button = sender
    }
    
    
    @IBAction func layoutButtonPressed(_ sender: UIButton) {
        // Clear all other button background
        // Change disposition
        sender.setBackgroundImage(#imageLiteral(resourceName: "Selected"), for: .normal)
    }
    
    
    
    
    func createImageFromGrid() {
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            gridView.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        imageView.image = image
    }
}



extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        button?.setBackgroundImage(image, for: .normal)
        button?.setImage(nil, for: .normal)
        createImageFromGrid()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

