//
//  ViewController.swift
//  Instagrid
//
//  Created by Sebastien Gaillard on 01/05/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var layoutSelectionButtons: [UIButton]!
    @IBOutlet var gridButtons: [UIButton]!
    
    @IBOutlet weak var gridView: UIView!
    
    @IBOutlet weak var swipeStackView: UIStackView!
    @IBOutlet weak var swipeLabel: UILabel!
    
    private var button: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panOnGridView(_:)))
        gridView.addGestureRecognizer(panGestureRecognizer)
        
        for button in layoutSelectionButtons {
            if button.tag == 3 {
                setImageButton(button: button)
            }
        }
        
        addSwipeGestureRecognizer(viewSize: view.bounds.size)
    }
    
    func addSwipeGestureRecognizer(viewSize: CGSize) {
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeOnShareStackView(_:)))
        let size = viewSize
        
        if size.height > size.width {
            for recognizer in swipeStackView.gestureRecognizers ?? [] {
                swipeStackView.removeGestureRecognizer(recognizer)
            }
            swipeLabel.text = "Swipe up to share"
            swipeGestureRecognizer.direction = .up
            swipeStackView.addGestureRecognizer(swipeGestureRecognizer)
        } else {
            for recognizer in swipeStackView.gestureRecognizers ?? [] {
                swipeStackView.removeGestureRecognizer(recognizer)
            }
            swipeLabel.text = "Swipe left to share"
            swipeGestureRecognizer.direction = .left
            swipeStackView.addGestureRecognizer(swipeGestureRecognizer)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        addSwipeGestureRecognizer(viewSize: size)
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
        
        for button in layoutSelectionButtons {
            if sender.tag == button.tag {
                button.isSelected = true
                setImageButton(button: button)
            } else {
                button.isSelected = false
            }
        }
        
        switch sender.tag {
        case 1:
            changeLayout(choice: 1)
        case 2:
            changeLayout(choice: 2)
        case 3:
            changeLayout(choice: 3)
        default:
            break
        }
    }
    
    func setImageButton(button: UIButton) {
        let image = button.image(for: .selected)!
        let targetSize = CGSize(width: button.bounds.width, height: button.bounds.height)
        
        let scaledImage = image.scalePreservingAspectRatio(
            targetSize: targetSize
        )
        button.setImage(scaledImage, for: .selected)
    }
    
    func changeLayout(choice: Int) {
        switch choice {
        case 1:
            for button in gridButtons {
                if button.tag == 2 {
                    button.isHidden = true
                } else {
                    button.isHidden = false
                }
            }
        case 2:
            for button in gridButtons {
                if button.tag == 4 {
                    button.isHidden = true
                } else {
                    button.isHidden = false
                }
            }
        case 3:
            for button in gridButtons {
                button.isHidden = false
            }
        default:
            break
        }
    }
    
    @objc func swipeOnShareStackView(_ sender: UISwipeGestureRecognizer) {
        print("Gesture fired")
        switch sender.state {
        case .began, .changed:
            print("Gesture fired")
        case .cancelled, .ended:
            presentShareSheet()
        default:
            break
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
    
    func createImageFromGrid() -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: gridView.bounds.size)
        let image = renderer.image { ctx in
            gridView.drawHierarchy(in: gridView.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    @objc func panOnGridView(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began, .changed:
            transformGridViewWith(gesture: sender)
        case .cancelled, .ended:
            let size = view.bounds
            
            if size.width > size.height { // Si on est en mode paysage
                if sender.location(in: self.view).x < view.center.x - 50 {
                    userLetGoOfGridView(direction: EnumDirection.left)
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.gridView.transform = .identity
                    }
                }
            } else {
                if sender.location(in: self.view).y < view.center.y - 50 {
                    userLetGoOfGridView(direction: EnumDirection.up)
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
    
    func userLetGoOfGridView(direction: EnumDirection) {
        
        let screenWidth = UIScreen.main.bounds.width
        var translationTransform: CGAffineTransform
        
        if direction == .up {
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
    
    func gridViewReturnToInitialPos() {
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.gridView.transform = .identity
        }, completion: nil)
    }
}

//MARK: - Extensions

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
