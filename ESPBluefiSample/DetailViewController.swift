//
//  DetailViewController.swift
//  ESPBluefiSample
//
//  Created by joey on 10/21/20.
//  Copyright © 2020 tecpal. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var blufiClient: BlufiClient?
    private var messages: [String] = []

    public var device: ESPPeripheral?
    public var isConnected: Bool = false

    @IBAction func connectAction(_ sender: Any) {
        guard device != nil else { return }

        blufiClient?.close()
        blufiClient = nil

        blufiClient = BlufiClient()
        blufiClient?.centralManagerDelete = self
        blufiClient?.peripheralDelegate = self
        blufiClient?.blufiDelegate = self
        blufiClient?.connect(device!.uuid.uuidString)
    }

    @IBAction func disconnectAction(_ sender: Any) {
        blufiClient?.requestCloseConnection()
    }

    @IBAction func bluefiAction(_ sender: Any) {
    }
}

extension DetailViewController: CBCentralManagerDelegate, CBPeripheralDelegate, BlufiDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        updateMessage("Connected device")
    }

    private func updateMessage(_ message: String) {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .none)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
