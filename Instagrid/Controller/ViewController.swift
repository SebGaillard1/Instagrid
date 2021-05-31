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
        let targetSize = CGSize(width: 80, height: 80)

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


extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}

