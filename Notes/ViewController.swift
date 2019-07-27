//
//  ViewController.swift
//  Notes
//
//  Created by user915640 on 7/26/19.
//  Copyright © 2019 user915640. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate {

    
    @IBOutlet weak var noteInfoView: UIView!
    @IBOutlet weak var noteImageViewView: UIView!
    @IBOutlet weak var noteNameLabel: UITextField!
    @IBOutlet weak var noteDescriptionLabel: UITextView!
    @IBOutlet weak var noteImageView: UIImageView!
    
    var managedObjectContext: NSManagedObjectContext? {
        return(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    var notesFetchedResultsController: NSFetchedResultsController<Note>!
    var notes = [Note]()
    var note: Note?
    var isExisting = false
    var indexPath = Int?.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let note = note {
            noteNameLabel.text = note.noteName
            noteDescriptionLabel.text = note.noteDescription
            noteImageView.image = UIImage(data: note.noteImage! as Data)
        }
        if noteNameLabel.text != ""{
            isExisting = true
        }
        
        noteNameLabel.delegate = self
        noteDescriptionLabel.delegate = self
        
        noteInfoView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0).cgColor
        
        noteInfoView.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        noteInfoView.layer.shadowRadius = 1.5
        noteInfoView.layer.shadowOpacity = 0.2
        
        noteImageViewView.layer.shadowColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0).cgColor
        
        noteImageViewView.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
        noteImageViewView.layer.shadowRadius = 1.5
        noteImageViewView.layer.shadowOpacity = 0.2
        
        noteNameLabel.setBottomBorder()
        
    }
    
    func saveToCoreData(completion: @escaping ()->Void){
        managedObjectContext!.perform {
            do{
                try self.managedObjectContext?.save()
                completion()
                print ("Note saved to core data.")
            }
            
            catch let error{
                print (error.localizedDescription + "Could not save note to CoreData")
            }
        }
    }

    @IBAction func pickImageButtonWasPressed(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add an image", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {(action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated:true, completion: nil)
            
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated:true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated:true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.noteImageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonWasPressed( sender: UIBarButtonItem){
        if noteNameLabel.text == "" || noteNameLabel.text == "NOTE NAME" || noteDescriptionLabel.text == "" || noteDescriptionLabel.text == "Note Description..."{
            let alertController = UIAlertController(title: "Missing Information", message: "You left one or more fields empty Please make sure that all fields are filled before attempting to save.", preferredStyle: UIAlertController.Style.alert)
            let OKAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil)
            
            alertController.addAction(OKAction)
            
            self.present(alertController,animated: true,completion: nil)
        }
        
        else {
            if(isExisting == false){
                let noteName = noteNameLabel.text
                let noteDescription = noteDescriptionLabel.text
                
                if let moc = managedObjectContext {
                    let note = Note(context: moc)
                    
                        if let data = noteImageView.image!.jpegData(compressionQuality: 1.0){
                            note.noteImage = data as Data
                        }
                    
                    note.noteName = noteName
                    note.noteDescription = noteDescription
                    
                    saveToCoreData {
                        let isPresentingInAddNoteMode = self.presentingViewController is UINavigationController
                        
                        if isPresentingInAddNoteMode {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            self.navigationController!.popViewController(animated: true)
                        }
                    }
                    
                    
                } else if(isExisting == true){
                    let note = self.note
                    let managedObject = note
                    managedObject!.setValue(noteNameLabel, forKey: "noteName")
                    managedObject!.setValue(noteDescriptionLabel, forKey: "noteDescription")
                    
                    if let data = noteImageView.image!.jpegData(compressionQuality: 1.0){
                        managedObject!.setValue(data, forKey: "noteImage")
                    }
                    do {
                        try context.save()
                        let isPresentingInAddNoteMode = self.presentingViewController is UINavigationController
                        
                        if isPresentingInAddNoteMode {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            self.navigationController!.popViewController(animated: true)
                        }
                    
                    } catch {
                        print("Failed to update existing note.")
                    }
                }
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddFluidPatientMode = presentingViewController is UINavigationController
        
        if isPresentingInAddFluidPatientMode {
            dismiss(animated: true, completion: nil)
            
        }
            
        else {
            navigationController!.popViewController(animated: true)
            
        }
        
    }
    
    // Text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
            
        }
        
        return true
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Note Description...") {
            textView.text = ""
            
        }
        
    }
    
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 245.0/255.0, green: 79.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
    


