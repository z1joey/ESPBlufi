//
//  TableViewController.swift
//  ESPBluefiSample
//
//  Created by joey on 10/20/20.
//  Copyright © 2020 tecpal. All rights reserved.
//

import UIKit
import ESPBluefi

class TableViewController: UITableViewController {
    private var dataSource: [ESPPeripheral] = []
    private var espFBYBleHelper: ESPFBYBLEHelper?
    private var filterContent: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        espFBYBleHelper = ESPFBYBLEHelper.share()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterContent = ESPDataConversion.loadBlufiScanFilter()
        scanDeviceInfo()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let device = sender as? ESPPeripheral {
            let detail = segue.destination as? DetailViewController
            detail?.device = device
        }
    }

    @IBAction func scanDeviceAction(_ sender: Any) {
        filterContent = ESPDataConversion.loadBlufiScanFilter()
        scanDeviceInfo()
    }

    private func scanDeviceInfo() {
        dataSource.removeAll()
        espFBYBleHelper?.startScan({ peripheral in
            self.dataSource.append(peripheral)
            self.tableView.reloadData()
        })
    }
}

extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let name = dataSource[indexPath.row].name
        let rssi = dataSource[indexPath.row].rssi

        cell.textLabel?.text = "\(name) \(rssi)"
        cell.detailTextLabel?.text = dataSource[indexPath.row].uuid.uuidString
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Detail", sender: dataSource[indexPath.row])
    }
}
