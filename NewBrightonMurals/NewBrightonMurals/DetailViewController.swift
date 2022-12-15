//
//  DetailViewController.swift
//  NewBrightonMurals
//
//  Created by Moldovan, Eusebiu on 09/12/2022.
//

import UIKit

class DetailViewController: UIViewController {

    
    //Connection from the main storyboard to be used to displaydata to the user
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    //Variables created to aid me, retrieve data and process images
    var mural:muralStructure? = nil
    var imagesArray = [UIImage]()
    var oneImage:UIImage? = nil
    var dictionary = [String:[UIImage]]()
    let attributes: [NSAttributedString.Key: Any] = [.font : UIFont.boldSystemFont(ofSize: 14)]
    
    
    //Main func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //We loop through all the images in that mural object, retrieving ech one and outting them into an array of images
        for image in mural!.images{
            if let oneImageURL = URL(string:("https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm_images/"+image.filename)){
                if let data = try? Data(contentsOf: oneImageURL){
                    self.oneImage = UIImage(data: data)!        //we set one image to the image we just retrieved
                    self.imagesArray.append(self.oneImage!)     //We append said image to the arrayfor it to be used later
                }
            }
        }
        
        //We print the first image to the UIImageView so that images have the correct orientation (Otherwise some of them rotate tofill the view)
        imageView.image = imagesArray[0]
        
        //Start animating multiple images withing the same UIImageView, allowing the user to see all the images without adding additional buttons etc.
        imageView.animationImages = imagesArray
        imageView.animationDuration = 4.0
        imageView.startAnimating()
        
        //--- Adding bold text tot part of the mural, mainly the name of the artist and the title of the murals
        
        //--- Create multiple NSAttibutes to use to make the strings
        let bold = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 14.0)!]
        let regular = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 14.0)!]
        
        //Make the bold strings
        let title = NSAttributedString(string: ""+(mural?.title ?? "unavailable"), attributes: bold)
        let artist = NSAttributedString(string: ""+(mural?.artist ?? "unavailable"), attributes: bold)
        
        //Add the bold and regular strings together
        let stringN = NSAttributedString(string:"\n", attributes: regular)
        let string1 = NSAttributedString(string:"Title: ", attributes: regular)
        let string2 = NSAttributedString(string:"Artist: ", attributes: regular)
        let string3 = NSAttributedString(string:"---------------", attributes: regular)
        let string4 = NSAttributedString(string:"Info: "+(mural?.info ?? "unavailable"), attributes: regular)
        
        //Configuring the final string, making it ready to print
        let final = NSMutableAttributedString()
        final.append(addString(left: string1, right: title))
        final.append(addString(left: stringN, right: string2))
        final.append(addString(left: artist, right: stringN))
        final.append(addString(left: string3, right: stringN))
        final.append(string4)
        
        //We change the text of the label, and use sizeToFit() on it so that it always starts from the top
        label.attributedText = final
        label.sizeToFit()
    }
    
    //Use this function to add two strings together, making it easier to format them
    func addString (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString{
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     
     {"id":"1",
     "title":"I See The Sea",
     "artist":"Ben Eine",
     "info":"Overlooking a secure car park Ben Eine's 'I See The Sea' is a bright neon yellow mural which is just pure fun. Known for his use of different typefaces he will often paint statements big and bold on walls he is asked to paint. If he's anything like me, growing up away from the seaside then the excited childish cry of 'I see the sea' was a familiar one when, on family trips, we got near the coast.",
     "thumbnail":"https:\/\/cgi.csc.liv.ac.uk\/~phil\/Teaching\/COMP228\/nbm_thumbs\/IMG_1065X.JPG",
     "lat":"53.43881250167621",
     "lon":"-3.0416222190640183",
     "enabled":"1",
     "lastModified":"2022-11-21 12:02:37",
     "images":[{"id":"1","filename":"IMG_1065X.JPG"}]}
    */

}
