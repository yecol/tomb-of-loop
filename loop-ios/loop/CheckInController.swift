//
//  CheckInController.swift
//  loop
//
//  Created by Yecol Hsu on 02/09/2016.
//  Copyright © 2016 Jingbo. All rights reserved.
//

import UIKit
import CoreLocation

private let kCheckinHeader = "kCheckinHeader"
private let kCheckinCell = "kCheckinCell"
fileprivate let KCheckInIconSize:CGFloat = 32;

class CheckInController: UITableViewController, CLLocationManagerDelegate {

    var delegate: PostControllerDelegate?

    var locationManager: CLLocationManager!
    
    var datasourceRequesting = false;

    private var checkinHeader: CheckInHeaderCell?;
    var selectedIndex = -1;

    var dataSource = NSMutableArray();

    override func viewDidLoad() {
        super.viewDidLoad()

        // set views
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = CL_GREY_BG_EC;

//        self.tableView.registerNib(UINib(nibName: "SeparatorCell", bundle: nil), forCellReuseIdentifier: "separator")

        // set navigation item
        let button = UIButton.init(type: .custom);
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 25);
        button.layer.borderColor = CL_GREEN_DEFAULT.cgColor;
        button.layer.cornerRadius = FL_CONNER_RADIUS;
        button.setTitle("kButton_CheckIn_CheckIn_Normal".localized, for: UIControlState());
        button.titleLabel?.font = fontMontserrat14
        button.setTitleColor(CL_GREEN_DEFAULT, for: UIControlState())
        button.layer.borderWidth = 1.0;
        button.addTarget(self, action: #selector(self.checkinBtnPressed), for: UIControlEvents.touchUpInside);

        let checkinButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = checkinButton

        let cancelButton = UIBarButtonItem.init(title: "kCancel".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.cancelBtnPressed))
        self.navigationItem.leftBarButtonItem = cancelButton

        // set color of navigation bar
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.tintColor = CL_GREEN_DEFAULT
        self.navigationController?.navigationBar.barTintColor = CL_GREY_NAVIBAR;
        //self.title = "Post New"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: CL_BLACK_GRACE, NSFontAttributeName: fontMontserrat16]
        title = "kTitle_CheckIn".localized;

        self.tableView.register(CheckInHeaderCell.self, forCellReuseIdentifier: kCheckinHeader);
        self.tableView.register(CheckInLocationCell.self, forCellReuseIdentifier: kCheckinCell);

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

        if(self.datasourceRequesting){
            return;
        }
        self.datasourceRequesting = true;
        self.showLoadingProgress();
        let position = AVGeoPoint.init(location: cur);

        DataModelManager.sharedInstance.cloudGetNearbyPlacesList(position, limit: kGetAllInOnePage, radius: 100, block: { (places:
                Array<Any>?, error: Error?) in
            self.datasourceRequesting = false;
            self.hideProgress();
            if (self.filterError(error)) {
                print(places!);
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
        if (self.dataSource.count == 0) {
            return 1;
        } else {
            return 2;
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1;
        } else {
            return self.dataSource.count
        };

    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 12;
        } else {
            return 6;
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6;
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 64
        default:
            return 56
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: kCheckinHeader, for: indexPath);
            //cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, cell.bounds.size.width)
            checkinHeader = cell as? CheckInHeaderCell;
            return cell;

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: kCheckinCell, for: indexPath) as! CheckInLocationCell;
            let place = self.dataSource.object(at: indexPath.row) as! LPPlace;
            cell.bindData(title: place.name ?? "", detailed: place.address ?? "", withIcon: place.iconUrl ?? "");
            return cell;
        }
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
        checkinHeader!.bindData(place);
//        self.tableView.setContentOffset(CGPoint.zero, animated: true)
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0 - self.tableView.contentInset.top), animated: true)
        tableView.deselectRow(at: indexPath, animated: true);
    }

    func checkinBtnPressed() {

        if (selectedIndex != -1) {
            let place = self.dataSource[selectedIndex] as! LPPlace;
            //place.placeId = "4e23a09252b1f82ffbb51557";

//            self.showComplete(with: "Checkin Successfully.")
            self.dismiss(animated: true, completion: {
                self.delegate?.dismissSilently();
                DataModelManager.sharedInstance.cloudCheckIn(place.placeId, block: { success, error in
                })
            });
        }
    }


    func exploreVenues() {
        guard let location = self.locationManager.location else {
            return
        }
        refresh(cur: location)
        DataModelManager.sharedInstance.updateLatestLocation(AVGeoPoint.init(location: location));
    }
}


private class CheckInHeaderCell: UITableViewCell {

    private lazy var placeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = CL_BLACK_GRACE;
        label.font = fontSystem14Bold;
        return label
    }()

    private lazy var placeDetailLabel: UILabel = {
        let label = UILabel()
        label.font = fontSystem14;
        label.textColor = CL_GREY_FONT;
        return label
    }()

    private lazy var placeIcon: UIImageView = {
        let imageView = UIImageView(frame: CGRect.null)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "checkin-location");
        return imageView
    }()

    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier);
        self.contentView.backgroundColor = UIColor.white;
        self.selectionStyle = .none

        self.contentView.addSubview(placeIcon);
        self.contentView.addSubview(placeNameLabel);
        self.contentView.addSubview(placeDetailLabel);

        self.addLayoutConstraints();
    }

    private func addLayoutConstraints() {

        self.contentView.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview();
            make.size.equalToSuperview();
        }

        self.placeIcon.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview();
            make.left.equalToSuperview().offset(kProfileSelfLeftSpacing)
            make.width.equalTo(KCheckInIconSize)
            make.height.equalTo(KCheckInIconSize)
        }

        self.placeNameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.placeIcon);
            make.left.equalTo(self.placeIcon.snp.right).offset(kProfileSelfLeftSpacing);
            make.width.equalToSuperview().offset(-kProfileSelfLeftSpacing * 3 - 32);
        }

        self.placeDetailLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.placeNameLabel.snp.bottom).offset(3);
            make.left.equalTo(self.placeNameLabel);
            make.width.equalTo(self.placeNameLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindData(_ place: LPPlace) {
        self.placeNameLabel.text = place.name ?? ""
        self.placeDetailLabel.text = place.address ?? ""
    }
}


class CheckInLocationCell: UITableViewCell {
    
    private lazy var placeNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = CL_BLACK_GRACE;
        label.font = fontSystem14Bold;
        return label
    }()
    
    private lazy var placeDetailLabel: UILabel = {
        let label = UILabel()
        label.font = fontSystem14;
        label.textColor = CL_GREY_FONT;
        return label
    }()
    
    private lazy var placeIcon: UIImageView = {
        let imageView = UIImageView(frame: CGRect.null)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var placeIconBg: UIImageView = {
        let imageView = UIImageView(frame: CGRect.null)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "checkin-frame");
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier);
        self.contentView.backgroundColor = UIColor.white;
        self.selectionStyle = .default;
        self.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
        
        self.contentView.addSubview(placeIconBg);
        self.contentView.addSubview(placeIcon);
        self.contentView.addSubview(placeNameLabel);
        self.contentView.addSubview(placeDetailLabel);
        
        self.addLayoutConstraints();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func addLayoutConstraints(){
        self.contentView.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview();
            make.size.equalToSuperview();
        }
        
        self.placeIconBg.snp.makeConstraints { (make) -> Void in
            make.centerY.equalToSuperview();
            make.left.equalToSuperview().offset(kProfileSelfLeftSpacing)
            make.width.equalTo(KCheckInIconSize)
            make.height.equalTo(KCheckInIconSize)
        }
        
        self.placeIcon.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(self.placeIconBg);
            make.size.equalTo(self.placeIconBg);
        }
        
        self.placeNameLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.placeIcon);
            make.left.equalTo(self.placeIcon.snp.right).offset(kProfileSelfLeftSpacing);
            make.width.equalToSuperview().offset(-kProfileSelfLeftSpacing * 3 - 32);
        }
        
        self.placeDetailLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.placeNameLabel.snp.bottom).offset(3);
            make.left.equalTo(self.placeNameLabel);
            make.width.equalTo(self.placeNameLabel)
        }
    }
    
    func bindData(title: String, detailed:String, withIcon iconUrl: String) {
        self.placeNameLabel.text = title;
        self.placeDetailLabel.text = detailed;
        self.placeIcon.sd_setImage(with: URL(string:iconUrl),placeholderImage: UIImage(named: "checkin-ph"));
    }
}

