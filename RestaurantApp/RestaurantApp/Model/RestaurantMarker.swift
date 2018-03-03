import Foundation
import MapKit

class RestaurantMarker: NSObject, MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    var image: String?
    var title: String?
    var phoneNumber: String?
    var category: String?
    var rating: Double?
    var reviewCount: Int?
    var address: String?
    var city: String?
    var country: String?
    var distance: Double?
    
    init(coordinate: CLLocationCoordinate2D, image: String, title: String, phoneNumber: String, category: String, rating: Double, reviewCount: Int, address: String, city: String, country: String, distance: Double) {
        self.coordinate = coordinate
        self.image = image
        self.title = title
        self.phoneNumber = phoneNumber
        self.category = category
        self.rating = rating
        self.reviewCount = reviewCount
        self.address = address
        self.city = city
        self.country = country
        self.distance = distance
    }

}
