//
//  ViewController.swift
//  Instagrid
//
//  Created by Sebastien Gaillard on 01/05/2021.
//

import UIKit

class ViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonsImageGrid(_ sender: UIButton) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.sourceType = .photoLibrary
        myPickerController.delegate = self
        myPickerController.allowsEditing = true
        //myPickerController.mediaTypes = []

        self.present(myPickerController, animated: true, completion: nil)
        //sender.setBackgroundImage(#imageLiteral(resourceName: "Icon"), for: .normal)
        sender.setImage(nil, for: .normal)
    }
    
    func getImage(image: UIImage) {
        
    }
}

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            getImage(image: image)
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

