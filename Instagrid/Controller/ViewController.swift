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
        
        //layoutButton3.setBackgroundImage(#imageLiteral(resourceName: "Selected"), for: .normal)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeGridView(_:)))
        gridView.addGestureRecognizer(panGestureRecognizer)
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
        
        switch sender.tag {
        case 1:
            layoutButton2.setBackgroundImage(nil, for: .normal)
            layoutButton3.setBackgroundImage(nil, for: .normal)
            changeLayout(choice: 1)
        case 2:
            layoutButton1.setBackgroundImage(nil, for: .normal)
            layoutButton3.setBackgroundImage(nil, for: .normal)
            changeLayout(choice: 2)
        case 3:
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
        
        let renderer = UIGraphicsImageRenderer(size: gridView.bounds.size)
        let image = renderer.image { ctx in
            gridView.drawHierarchy(in: gridView.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    @objc func swipeGridView(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began, .changed:
            transformGridViewWith(gesture: sender)
        case .cancelled, .ended:
            let size = view.bounds
            
            if size.width > size.height { // Si on est en mode paysage
                if sender.location(in: self.view).x < view.center.x - 50 {
                    userLetGoOfGridView(direction: "left")
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.gridView.transform = .identity
                    }
                }
            } else {
                if sender.location(in: self.view).y < view.center.y - 50 {
                    userLetGoOfGridView(direction: "up")
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.gridView.transform = .identity
                    }
                }
            }
        default:
            break
        }
    }
    
    func transformGridViewWith(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gridView)
        let translationTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
        gridView.transform = translationTransform
    }
    
    func userLetGoOfGridView(direction: String) {
        
        let screenWidth = UIScreen.main.bounds.width
        var translationTransform: CGAffineTransform

        if direction == "up" {
            translationTransform = CGAffineTransform(translationX: 0, y: -screenWidth - gridView.bounds.height)
        } else {
            translationTransform = CGAffineTransform(translationX: -screenWidth - gridView.bounds.width, y: 0)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.gridView.transform = translationTransform
        } completion: { (success) in
            if success {
                self.presentShareSheet()
            }
        }
    }
    
    func presentShareSheet() {
        
        let image = createImageFromGrid()
        let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        ac.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                self.gridViewReturnToInitialPos()
                return
            }
            self.gridViewReturnToInitialPos()
        }
        
        present(ac, animated: true)
    }
    
    func gridViewReturnToInitialPos() {
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.gridView.transform = .identity
        }, completion: nil)
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

