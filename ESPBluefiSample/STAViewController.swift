//
//  STAViewController.swift
//  ESPBluefiSample
//
//  Created by joey on 10/22/20.
//  Copyright © 2020 tecpal. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreLocation

class STAViewController: UIViewController {
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    private var locationManager: CLLocationManager?

    public weak var paramsDelegate: ConfigureParamsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //if getUserLocationAuth() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
        //}
    }

    @IBAction func saveAction(_ sender: Any) {
        guard let ssid = ssidTextField.text, let password = passwordTextField.text else { return }

        let params = BlufiConfigureParams()
        params.opMode = OpModeSta
        params.staSsid = ssid
        params.staPassword = password

        paramsDelegate?.didSetParams(params: params)
        navigationController?.popViewController(animated: true)
    }

    private func getSSID() -> String? {
        guard let interface = (CNCopySupportedInterfaces() as? [String])?.first,
            let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
            let ssid = unsafeInterfaceData["SSID"] as? String else{
                return nil
        }
        return ssid
    }

//    private func getUserLocationAuth() -> Bool {
//        switch CLLocationManager.authorizationStatus() {
//        case .notDetermined, .restricted, .denied:
//            return false
//        case .authorizedAlways, .authorizedWhenInUse:
//            return true
//        default:
//            return false
//        }
//    }
}

extension STAViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldShowAlert = false

        switch status {
        case .notDetermined, .restricted, .authorizedAlways, .authorizedWhenInUse:
            break
        case .denied:
            shouldShowAlert = true
            break
        default:
            break
        }

        if shouldShowAlert {
            print("should go to setting")
        } else {
            ssidTextField.text = getSSID()
            passwordTextField.text = "vpn4test"
        }
    }
}

public protocol ConfigureParamsDelegate: class {
    func didSetParams(params: BlufiConfigureParams)
}
