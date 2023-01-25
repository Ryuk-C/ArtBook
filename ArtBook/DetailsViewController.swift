//
//  DetailsViewController.swift
//  ArtBook
//
//  Created by Cuma on 25/01/2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var artist: UITextField!
    @IBOutlet weak var year: UITextField!

    @IBOutlet weak var savebutton: UIButton!

    var chosenImage = ""
    var chosenImageId: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenImage != "" {

            savebutton.isHidden = true

            //Core Data

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
            let idString = chosenImageId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false

            do {
                let results = try context.fetch(fetchRequest)

                if results.count > 0 {

                    for result in results as! [NSManagedObject] {

                        if let validName = result.value(forKey: "name") as? String {
                            name.text = validName
                        }

                        if let validArtist = result.value(forKey: "artist") as? String {
                            artist.text = validArtist
                        }

                        if let validYear = result.value(forKey: "year") as? Int {
                            year.text = String(validYear)
                        }

                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }

                    }
                }

            } catch {
                print("error")
            }
        }
        else {
            savebutton.isHidden = false
            savebutton.isEnabled = false
        }

        //Recognizers

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeykoard))
        view.addGestureRecognizer(gestureRecognizer)

        imageView.isUserInteractionEnabled = true

        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))

        imageView.addGestureRecognizer(imageTapRecognizer)
    }


    @IBAction func saveButtonClicked(_ sender: Any) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Images", into: context)

        //Attributes

        newPainting.setValue(name.text!, forKey: "name")
        newPainting.setValue(artist.text!, forKey: "artist")

        if let year = Int(year.text!) {
            newPainting.setValue(year, forKey: "year")
        }

        newPainting.setValue(UUID(), forKey: "id")

        let data = imageView.image!.jpegData(compressionQuality: 0.5)

        newPainting.setValue(data, forKey: "image")

        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }


        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }

    @objc func hideKeykoard() {
        view.endEditing(true)
    }

    @objc func selectImage() {

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imageView.image = info[.originalImage] as? UIImage
        savebutton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
}
