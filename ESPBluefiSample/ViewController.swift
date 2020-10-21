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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        espFBYBleHelper = ESPFBYBLEHelper.share()
    }

    private func scanDeviceInfo() {
        dataSource.removeAll()
        espFBYBleHelper?.startScan({ peripheral in
            self.dataSource.append(peripheral)
            self.tableView.reloadData()
        })
    }
}

