//
//  ViewController.swift
//  Instagrid
//
//  Created by Sebastien Gaillard on 01/05/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var layoutButton1: UIButton!
    @IBOutlet weak var layoutButton2: UIButton!
    @IBOutlet weak var layoutButton3: UIButton!
    
    @IBOutlet weak var gridButton1: UIButton!
    @IBOutlet weak var gridButton2: UIButton!
    @IBOutlet weak var gridButton3: UIButton!
    @IBOutlet weak var gridButton4: UIButton!
    
    @IBOutlet weak var gridView: UIView!
    
    var button: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeGridView(_:)))
        let size = view.bounds
        
        if size.height > size.width {
            swipeGestureRecognizer.direction = .up
        } else {
            swipeGestureRecognizer.direction = .left
        }
        
        gridView.addGestureRecognizer(swipeGestureRecognizer)
        gridView.isUserInteractionEnabled = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        for recognizer in gridView.gestureRecognizers ?? [] {
            gridView.removeGestureRecognizer(recognizer)
        }
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeGridView(_:)))
        let size = view.bounds
        
        if size.width > size.height {
            swipeGestureRecognizer.direction = .up
        } else {
            swipeGestureRecognizer.direction = .left
        }
        
        gridView.addGestureRecognizer(swipeGestureRecognizer)
        gridView.isUserInteractionEnabled = true
    }
    
    @IBAction func buttonImageGridPressed(_ sender: UIButton) {
        
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        pickerController.allowsEditing = true

        self.present(pickerController, animated: true, completion: nil)
        button = sender
    }
    
    // Clear all other button background
    // Call function changeLayout with appropriate parameter
    @IBAction func layoutButtonPressed(_ sender: UIButton) {
        
        switch sender.title(for: .normal) {
        case "1":
            layoutButton2.setBackgroundImage(nil, for: .normal)
            layoutButton3.setBackgroundImage(nil, for: .normal)
            changeLayout(choice: 1)
        case "2":
            layoutButton1.setBackgroundImage(nil, for: .normal)
            layoutButton3.setBackgroundImage(nil, for: .normal)
            changeLayout(choice: 2)
        case "3":
            layoutButton1.setBackgroundImage(nil, for: .normal)
            layoutButton2.setBackgroundImage(nil, for: .normal)
            changeLayout(choice: 3)
        default:
            break
        }
        sender.setBackgroundImage(#imageLiteral(resourceName: "Selected"), for: .normal)
    }
    
    func changeLayout(choice: Int) {
        switch choice {
        case 1:
            gridButton1.isHidden = false
            gridButton2.isHidden = true
            gridButton3.isHidden = false
            gridButton4.isHidden = false
        case 2:
            gridButton1.isHidden = false
            gridButton2.isHidden = false
            gridButton3.isHidden = false
            gridButton4.isHidden = true
        case 3:
            gridButton1.isHidden = false
            gridButton2.isHidden = false
            gridButton3.isHidden = false
            gridButton4.isHidden = false
        default:
            break
        }
    }
    
    func createImageFromGrid() -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            gridView.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    @objc func swipeGridView(_ sender: UISwipeGestureRecognizer) {
        print("Gesture fired")
    }
}



extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        button?.setBackgroundImage(image, for: .normal)
        button?.setImage(nil, for: .normal)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

