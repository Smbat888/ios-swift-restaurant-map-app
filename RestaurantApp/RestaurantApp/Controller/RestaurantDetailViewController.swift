import UIKit
import AARatingBar


class RestaurantDetailViewController: UIViewController {

    @IBOutlet weak var ratingBar: AARatingBar!
    @IBOutlet weak var restImg: UIImageView!

    @IBOutlet weak var countryAndCity: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var adress: UILabel!
    
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var name: UILabel!
    var chosenMarker: RestaurantMarker? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillViewData()
    }

    @IBAction func dismissDetail(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func fillViewData() {
        let floatRating = NSNumber.init(value: (chosenMarker?.rating)!).floatValue
        let rating = CGFloat(floatRating)
        ratingBar.value = rating
        ratingBar.isEnabled = false;
        ratingBar.backgroundColor = UIColor.clear
        AppHelper.downloadImage(imageView: restImg, imageUrl: chosenMarker!.image!)
        countryAndCity.text = "\(String(describing: chosenMarker!.city)), \(String(describing: chosenMarker!.country))"
        adress.text = chosenMarker?.address
        phone.text = chosenMarker?.phoneNumber
        name.text = chosenMarker?.title
    }
}
