//
//  ViewController.swift
//  Instagrid
//
//  Created by Sebastien Gaillard on 01/05/2021.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var layoutSelectionButtons: [UIButton]!
    @IBOutlet var gridButtons: [UIButton]!
    
    @IBOutlet weak var gridView: UIView!
    
    @IBOutlet weak var swipeStackView: UIStackView!
    @IBOutlet weak var swipeLabel: UILabel!
    
    // MARK: - Properties
    private var button: UIButton?
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panOnGridView(_:)))
        gridView.addGestureRecognizer(panGestureRecognizer)
        
        for button in layoutSelectionButtons {
            if button.tag == 3 {
                setImageToButton(button: button)
            }
        }
        
        addSwipeGestureRecognizer(viewSize: view.bounds.size)
    }
    
    // Ajoute le swipeGestureRecognizer à la swipeStackView
    private func addSwipeGestureRecognizer(viewSize: CGSize) {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeOnShareStackView(_:)))
        let size = viewSize
        
        for recognizer in swipeStackView.gestureRecognizers ?? [] {
            swipeStackView.removeGestureRecognizer(recognizer)
        }
        
        if size.height > size.width {
            swipeGestureRecognizer.direction = .up
            swipeStackView.addGestureRecognizer(swipeGestureRecognizer)
        } else {
            swipeGestureRecognizer.direction = .left
            swipeStackView.addGestureRecognizer(swipeGestureRecognizer)
        }
    }
    
    // Appelée juste avant que l'écran passe de portrait <-> paysage
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        addSwipeGestureRecognizer(viewSize: size)
        
        if size.height > size.width {
            swipeLabel.text = "Swipe up to share"
        } else {
            swipeLabel.text = "Swipe left to share"
        }
    }
    
    // Présente le UIImagePickerController lors d'un appui sur un bouton
    @IBAction func buttonImageGridPressed(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        self.present(pickerController, animated: true, completion: nil)
        button = sender
    }
    
    // Quand user appuie sur un bouton pour choisir un layout : Changement du bouton selectionné et de son background et
    // appel de la méthode qui change le layout
    @IBAction func layoutButtonPressed(_ sender: UIButton) {
        for button in layoutSelectionButtons {
            if sender.tag == button.tag {
                button.isSelected = true
                setImageToButton(button: button)
                changeLayout(choice: sender.tag)
            } else {
                button.isSelected = false
            }
        }
    }
    
    // Cette méthode change la disposition de la gridView en cachant ou non des boutons
    private func changeLayout(choice: Int) {
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
    
    // Méthode appelée par le SwipeGestureRecognizer. Elle appelle la méthode qui affiche la shareSheet
    @objc func swipeOnShareStackView(_ sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .ended:
            presentShareSheet()
        default:
            break
        }
    }
    
    // Cette méthode appelle la méthode qui crée l'image de la création photo de l'utilisateur.
    // Elle initialise une shareSheet afin de partager l'image qui vient d'être créée
    private func presentShareSheet() {
        let image = createImageFromGrid()
        let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        ac.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            self.gridViewReturnToInitialPos() // Nécessaire sinon la gridView ne reviens pas après partage
        }
        
        present(ac, animated: true)
    }
    
    // Cette méthode permet de générer une UIImage de la gridView et de son contenu
    private func createImageFromGrid() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: gridView.bounds.size)
        let image = renderer.image { ctx in
            gridView.drawHierarchy(in: gridView.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    // Cette méthode est appelée par le PanGestureRecognizer.
    // Elle permet à la gridView de se déplacer avec le doigt de l'utilisateur en appelant transformGridView() à chaque changement de pos
    // Elle appelle la méthode userLetGoOfGrid() si le swipe est valide. Sinon la gridView est recentrée
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
    
    // Applique une transformation à la gridView afin de suivre le doigt de l'utilisateur
    private func transformGridViewWith(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gridView)
        let translationTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
        gridView.transform = translationTransform
    }
    
    // Méthode appelée quand l'utilistateur lache la gridView dans la bonne direction
    // Anime le départ de la gridView et présente la shareSheet
    private func userLetGoOfGridView(direction: EnumDirection) {
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
    
    // Cette méthode permet le retour à la position initiale de la gridView avec une animation
    private func gridViewReturnToInitialPos() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.gridView.transform = .identity
        }, completion: nil)
    }
    
    // Redimensionne la background image du bouton à la dimension du bouton
    private func setImageToButton(button: UIButton) {
        let image = button.image(for: .selected)!
        let targetSize = CGSize(width: button.bounds.width, height: button.bounds.height)
        let scaledImage = image.scalePreservingAspectRatio(
            targetSize: targetSize
        )
        button.setImage(scaledImage, for: .selected)
    }
}

//MARK: - Extensions

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // Appelée quand l'utilisateur a choisi une image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        button?.setBackgroundImage(image, for: .normal)
        button?.setImage(nil, for: .normal)
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Appelée quand l'utilisateur annule sa sélection d'image.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
