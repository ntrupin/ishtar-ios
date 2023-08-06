//
//  LocationDemo.swift
//  project1810
//
//  Created by Noah Trupin on 10/3/21.
//

/*
 func requestProxy(_ coords: [Double]) {
     self.closest = "Loading..."
     let url = URL(string: "http://172.20.10.6:5000/endpoint")!
     let body = try? JSONSerialization.data(withJSONObject: coords)
     var request = URLRequest(url: url)
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
     request.httpMethod = "POST"
     request.httpBody = body
     let task = URLSession.shared.dataTask(with: request) { data, response, error in
         guard let data = data,
               let response = response as? HTTPURLResponse,
               error == nil else {
                   self.closest = error?.localizedDescription ?? "Error"
                   return
         }
         guard (200...299) ~= response.statusCode else {
             self.closest = "Invalid status code \(response.statusCode)"
             return
         }
         let resp = try? JSONSerialization.jsonObject(with: data, options: [])
         guard let resp = resp as? [String: Any] else {
             self.closest = "Error reading JSON."
             return
         }
         print(resp)
         self.closest = resp["name"] as! String
     }
     task.resume()
 }
 
 class LocationObject: NSObject, ObservableObject, CLLocationManagerDelegate {
     @Published var coords: [Double] = [0.0, 0.0]
     @Published var updated: Bool = false
     var locationManager: CLLocationManager!
     
     override init() {
         super.init()
         self.locationManager = CLLocationManager()
         //self.locationManager.requestAlwaysAuthorization()
         self.locationManager.requestWhenInUseAuthorization()
         if CLLocationManager.locationServicesEnabled() {
             locationManager.delegate = self
             locationManager.desiredAccuracy = kCLLocationAccuracyBest
             locationManager.startUpdatingLocation()
         }
     }
     
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
         if abs(coords[0] - locValue.latitude) > 0.000100 ||
             abs(coords[1] - locValue.longitude) > 0.000100 {
             if coords != [0.0, 0.0] {
                 self.updated = true
             }
             self.coords = [locValue.latitude, locValue.longitude]
         }
     }
 }
 */
