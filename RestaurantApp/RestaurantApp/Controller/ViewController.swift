import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    let API_KEY = "7plWN-NxQjszhhSSQOGy7zVPb31aCceqQxTQz9P5IbYWr3-_Oe8DZpkNNUsNG8iBFMuyPVt01HrLNcicnmgj5x8SSNw-fMasCcFwRZi5Q_cIX_pDCCXC_5hSF_iWWnYx"
    let ROOT_URL = "https://api.yelp.com/v3/businesses/search?term=restaurants"
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    var markersArray = [RestaurantMarker]()
    var selectedAnnotation: MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? MKPointAnnotation
        performSegue(withIdentifier: "showDetailView", sender: nil)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
//        var coords = CLLocationCoordinate2D()
//        coords.latitude = 37.767413217936834
//        coords.longitude = -122.42820739746094
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coords, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annoIdentifier = "Restaurant"
        var annotationView: MKAnnotationView?
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        if let annotationView = annotationView, let _ = annotation as? RestaurantMarker {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "map")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(annotationView.image, for: .normal)
            btn.sendActions(for: .touchUpInside)
            let gestureRecognizer = UITapGestureRecognizer(target: self,  action: #selector(showDetails(sender: )))
            gestureRecognizer.delegate = self
            annotationView.addGestureRecognizer(gestureRecognizer)
            annotationView.rightCalloutAccessoryView = btn
        }
        return annotationView
    }
    
    @objc func showDetails(sender: UIGestureRecognizer) {
//        performSegue(withIdentifier: "showDetailView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
                var rest = markersArray[0]
                for marker in markersArray {
                    if(marker == selectedAnnotation) {
                        rest = marker
                        break
                    }
                }
                let controller = segue.destination as? RestaurantDetailViewController
                controller?.chosenMarker = RestaurantMarker(coordinate: rest.coordinate, image: rest.image!, title: rest.title!, phoneNumber: rest.phoneNumber!, category:  rest.category!, rating: rest.rating!, reviewCount: rest.reviewCount!, address:rest.address!, city: rest.city!, country: rest.country!, distance: rest.distance! )
            }
    }
    
    func showSightingsOnMap(location: CLLocation) {
        fetchRestaurants(location: location)
        for marker in markersArray {
            self.mapView.addAnnotation(marker)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showSightingsOnMap(location: loc)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let anno = view.annotation as? RestaurantMarker {
            var place: MKPlacemark!
            if #available(iOS 10.0, *) {
                place = MKPlacemark(coordinate: anno.coordinate)
            } else {
                place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: nil)
            }
            let destination = MKMapItem(placemark: place)
            destination.name = "Restaurant Sighting"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey:  NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    func fetchRestaurants(location: CLLocation) {
        let scriptUrl = ROOT_URL
        // TO-DO just for testing for my current location
//        let urlWithParams = scriptUrl + "&latitude=37.767413217936834&longitude=-122.42820739746094"
        let urlWithParams = scriptUrl + "&latitude=\(location.coordinate.latitude)&longitude=\(location.coordinate.longitude)"
        // Create NSURL Ibject
        let myUrl = NSURL(string: urlWithParams);
        // Creaste URL Request
        let request = NSMutableURLRequest(url:myUrl! as URL);
        // Set request HTTP method to GET. It could be POST as well
        request.httpMethod = "GET"
        request.addValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            // Check for error
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            self.convertResponseJson(data: data)
        }
        task.resume()
    }
    
    func convertResponseJson(data: Data?) {
        // Convert server json response to NSDictionary
        do {
            if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                // Get value by key
                let firstNameValue = convertedJsonIntoDict["businesses"]
                print( (firstNameValue! as AnyObject).count)
                print(firstNameValue!)
                fillMapMarkers(restaurants: firstNameValue as! Array<Any>)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func fillMapMarkers(restaurants: Array<Any>) {
        for rest in restaurants {
            var latitude: Double?
            var longitude: Double?
            var title: String?
            var image: String?
            var phoneNumber: String?
            var rating: Double?
            var category: String?
            var reviewCount: Int?
            var city:String?
            var country: String?
            var address: String?
            var distance: Double?
            
            if let dictionary = rest as? [String: Any] {
                if let coordinates = dictionary["coordinates"] as? [String: Any] {
                    for i in coordinates {
                        if i.key.elementsEqual("latitude") {
                            latitude = i.value as? Double
                        } else if i.key.elementsEqual("longitude") {
                            longitude = i.value as? Double
                        }
                    }
                }
                if let categories = dictionary["categories"] as? [Any] {
                    let dict = categories[0] as! NSDictionary
                    category = "\(dict["title"]!) && \(dict["alias"]!)"
                    
                }
                if let name = dictionary["name"] as? String {
                    title = name
                }
                if let phone = dictionary["phone"] as? String {
                    phoneNumber = phone
                }
                if let imageUrl = dictionary["image_url"] as? String {
                    image = imageUrl
                }
                if let restRating = dictionary["rating"] as? Double {
                    rating = restRating
                }
                if let location = dictionary["location"] as? [String: Any] {
                    city = location["city"]! as? String
                    country = location["country"]! as? String
                    address = location["address1"]! as? String
                }
                reviewCount = dictionary["review_count"]! as? Int
                distance = dictionary["distance"]! as? Double
                var coords = CLLocationCoordinate2D()
                coords.latitude = latitude!
                coords.longitude = longitude!
                let restObj = RestaurantMarker(coordinate: coords, image: image!, title: title!, phoneNumber: phoneNumber!, category: category!, rating: rating!, reviewCount: reviewCount!, address:address!, city: city!, country: country!, distance: distance! )
                markersArray.append(restObj)
            }
        }
    }
}
