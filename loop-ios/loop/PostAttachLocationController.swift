//
//  PostAttachLocationController.swift
//  loop
//
//  Created by Yecol Hsu on 28/11/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import CoreLocation


protocol PostAttachLocationDelegate: class {
    func attachLocation(_ place: LPPlace);
}

private let kCheckinCell = "kCheckinCell"

class PostAttachLocationController: UITableViewController, CLLocationManagerDelegate {

    var delegate: PostAttachLocationDelegate?

    var locationManager: CLLocationManager!

    var selectedIndex = -1;

    var dataSource = NSMutableArray();

    override func viewDidLoad() {
        super.viewDidLoad()

        // set views
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = CL_GREY_BG_EC;
        
        self.tableView.register(CheckInLocationCell.self, forCellReuseIdentifier: kCheckinCell)

        let cancelButton = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancelBtnPressed))
        self.navigationItem.leftBarButtonItem = cancelButton

        // set color of navigation bar
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.tintColor = CL_GREEN_DEFAULT
        self.navigationController?.navigationBar.barTintColor = CL_GREY_NAVIBAR;
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: CL_BLACK_GRACE, NSFontAttributeName: fontMontserrat16]
        title = "kTitle_PostNew_AttachPlace".localized;


        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if status == CLAuthorizationStatus.authorizedWhenInUse
        || status == CLAuthorizationStatus.authorizedAlways {
            self.locationManager.startUpdatingLocation()
        } else {
            self.displayAlertView("kAlert_CannotGotLocation".localized);
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func refresh(cur: CLLocation) {

        let position = AVGeoPoint.init(location: cur);
        self.showLoadingProgress()
        DataModelManager.sharedInstance.cloudGetNearbyPlacesList(position, limit: 100, radius: 100, block: { (places: Array<Any>?, error: Error?) in
            self.hideProgress()
            if(self.filterError(error)) {
                self.dataSource = NSMutableArray.init(array: places!)
                self.tableView!.dataSource = self;
                self.tableView!.reloadData()
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cancelBtnPressed() {
        self.dismiss(animated: true, completion: nil);
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if(self.dataSource.count != 0) {
            return 1;
        } else {
            return 0;
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count ;
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 12;
        }
            else {
            return 6;
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6;
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCheckinCell, for: indexPath) as! CheckInLocationCell;
        let place = self.dataSource.object(at: indexPath.row) as! LPPlace
        cell.bindData(title: place.name ?? "", detailed: place.address ?? "", withIcon: place.iconUrl ?? "")
        return cell;
    }



    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            self.displayAlertView("kAlert_CannotGotLocation".localized)
        } else {
            self.locationManager.startUpdatingLocation()
        }
    }

    //
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            exploreVenues()
            self.locationManager.stopUpdatingLocation()
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row;
        let place = self.dataSource[selectedIndex] as! LPPlace;
        
        self.delegate?.attachLocation(place);
        self.dismiss(animated: true, completion: nil);
    }


    func exploreVenues() {
        guard let location = self.locationManager.location else {
            return
        }
        refresh(cur: location)
    }
}




//    var session: Session!
//    var locationManager: CLLocationManager!
//    var venueItems: JSON!

//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // set views
//        self.tableView.backgroundView = nil
//        self.tableView.backgroundColor = CL_GREY_BG_EC;
//
//        self.tableView.register(CheckinLocationCell.self, forCellReuseIdentifier: kCheckinCellIndentifier)
//
//        let cancelButton = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancelBtnPressed))
//        self.navigationItem.leftBarButtonItem = cancelButton
//
//        // set color of navigation bar
//        self.navigationController?.navigationBar.barStyle = .default
//        self.navigationController?.navigationBar.tintColor = CL_GREEN_DEFAULT
//        self.navigationController?.navigationBar.barTintColor = CL_GREY_NAVIBAR;
//        //self.title = "Post New"
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: CL_BLACK_GRACE, NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 17)!]
//        title = "Places";
//
//
//        // Do any additional setup after loading the view.
//        self.session = Session.sharedSession()
//        self.session.logger = ConsoleLogger()
//
//        self.locationManager = CLLocationManager()
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        self.locationManager.delegate = self
//        let status = CLLocationManager.authorizationStatus()
//        if status == .notDetermined {
//            self.locationManager.requestWhenInUseAuthorization()
//        } else if status == CLAuthorizationStatus.authorizedWhenInUse
//        || status == CLAuthorizationStatus.authorizedAlways {
//            self.locationManager.startUpdatingLocation()
//        } else {
//            self.displayAlertView("Cannot get location");
//        }
//    }
//
//    func cancelBtnPressed() {
//        self.dismiss(animated: true, completion: nil);
//    }
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        if(self.venueItems != nil) {
//            return 1;
//        }
//            else {
//            return 0;
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.venueItems.array!.count;
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60;
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: kCheckinCellIndentifier, for: indexPath) as! CheckinLocationCell
//            let venue = self.venueItems[indexPath.row];
//            let venueName = venue["name"].string;
//            var address = venue["location"]["address"].stringValue;
//            let city = venue["location"]["city"].stringValue;
//            if(address != "" && city != "") {
//                address += ", " + city;
//            }
//                else if(address == "" && city == "") {
//                address = venue["location"]["country"].stringValue;
//            }
//                else {
//                address = (address != "" ? address : city)
//            }
//
//        let iconUrl = venue["categories"][0]["icon"]["prefix"].stringValue + "64" + venue["categories"][0]["icon"]["suffix"].stringValue;
//        cell.setup(venueName!, detailed: address, withIcon: iconUrl)
//
////            cell.venueAddress.text = address;
////            let catIconURL =
////            cell.venueCatelogImage.sd_setImageWithURL(NSURL(string: catIconURL), placeholderImage: UIImage(named: "checkin-ph"));
//
//            return cell;
//    }
//
//
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .denied || status == .restricted {
//            self.displayAlertView("cannot get current location")
//        } else {
//            self.locationManager.startUpdatingLocation()
//        }
//    }
//
//    //
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if locations.first != nil {
//            //            if self.venueItems == nil {
//            exploreVenues()
//            //            }
//            //            self.resultsTableViewController.location = newLocation
//            self.locationManager.stopUpdatingLocation()
//        }
//    }
//
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        //        let friend = self.dataSource.objectAtIndex(indexPath.row) as! AVUser;
//        //        let profileController = ProfilePublicController();
//        //        profileController.setData(friend);
//        //        self.navigationController!.pushViewController(profileController, animated: true);
////        selectedIndex = indexPath.section - 1;
////        checkinHeader?.setPlace(self.venueItems[indexPath.section - 1]["name"].string!)
//        selectAtIndex(indexPath.row);
//        tableView.deselectRow(at: indexPath, animated: true);
//    }
//
//    func selectAtIndex(_ index:Int) {
//
//        if(index != -1) {
//            let venue = self.venueItems[index];
//            //            print("venue detailed:", venue);
//            //        }
//
//            let venueName = venue["name"].string;
//
//            var address = venue["location"]["address"].stringValue;
//            let city = venue["location"]["city"].stringValue;
//            if(address != "" && city != "") {
//                address += ", " + city;
//            }
//                else if(address == "" && city == "") {
//                address = venue["location"]["country"].stringValue;
//            }
//                else {
//                address = (address != "" ? address : city)
//            }
//
//            let catIconURL = venue["categories"][0]["icon"]["prefix"].stringValue + "64" + venue["categories"][0]["icon"]["suffix"].stringValue;
//
//            let lat = venue["location"]["lat"].doubleValue;
//            let lng = venue["location"]["lng"].doubleValue;
//
//            let venueId = venue["id"].stringValue;
//            let venueCatId = venue["categories"][0]["id"].stringValue;
//
//            let place = LPPlace();
//            place.name = venueName;
//            place.address = address;
//            place.foursquareId = venueId;
//            place.foursquareCategoryId = venueCatId;
//            place.latLng = AVGeoPoint(latitude: lat, longitude: lng);
//            place.iconUrl = catIconURL;
//
//            self.delegate?.attachLocationWithPlace(place);
//            self.dismiss(animated: true, completion: nil);
//        }
//    }

//    func exploreVenues() {
//    }

//        print("begin to search fourSquare")
//        guard let location = self.locationManager.location else {
//            return
//        }
//
////        var parameters = location.parameters()
//        parameters += [Parameter.intent: "checkin"];
//        let task = self.session.venues.search(parameters) {
//            (result) -> Void in
//
//            if(result.response == nil){
//                self.displayAlertView("network error")
//                return;
//            }
//
//            let response = JSON(result.response!);
//            self.venueItems = response["venues"];
//            self.tableView.reloadData();
//            //            }
//
//            //            if let response = result.response {
//            //                if let venue = response["venue"] as? JSONParameters,
//            //                    let tips = venue["tips"] as? JSONParameters {
//            //                    var tipItems = [JSONParameters]()
//            //                    if let groups = tips["groups"] as? [JSONParameters] {
//            //                        for group in groups {
//            //                            if let item = group["items"] as? [JSONParameters] {
//            //                                tipItems += item
//            //                            }
//            //                        }
//            //                    }
//            //                    self.tips = tipItems
//            //                }
//            //            } else {
//            //                // Show error.
//            //            }
//            //            self.tableView.reloadData()
//
//
//            //            if self.venueItems != nil {
//            //                return
//            //            }
//            //            if !Thread.isMainThread {
//            //                fatalError("!!!")
//            //            }
//            //
//            //            if let response = result.response {
//            //                if let groups = response["groups"] as? [[String: AnyObject]]  {
//            //                    var venues = [[String: AnyObject]]()
//            //                    for group in groups {
//            //                        if let items = group["items"] as? [[String: AnyObject]] {
//            //                            venues += items
//            //                        }
//            //                    }
//            //
//            //                    self.venueItems = venues
//            //                }
//            //                self.tableView.reloadData()
//            //            } else if let error = result.error , !result.isCancelled() {
//            //                self.showErrorAlert(error)
//            //            }
//        }
//        task.start()
//    }
    /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         }
         */
