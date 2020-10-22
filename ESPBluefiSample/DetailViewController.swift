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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sta = segue.destination as? STAViewController {
            sta.paramsDelegate = self
        }
    }

    @IBAction func connectAction(_ sender: Any) {
        guard device != nil else { return }

        blufiClient?.close()
        blufiClient = nil

        blufiClient = BlufiClient()
        blufiClient?.centralManagerDelete = self
//        blufiClient?.peripheralDelegate = self
        blufiClient?.blufiDelegate = self
        blufiClient?.connect(device!.uuid.uuidString)
    }

    @IBAction func disconnectAction(_ sender: Any) {
        blufiClient?.requestCloseConnection()
    }

    @IBAction func bluefiAction(_ sender: Any) {
    }

    private func updateMessage(_ message: String) {
        messages.append(message)
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .none)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

// MARK: - CBCentralManagerDelegate
extension DetailViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        updateMessage("Connected device")
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        updateMessage("Connecting device failed")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        updateMessage("Disconnected device")
    }
}

// MARK: - BlufiDelegate
extension DetailViewController: BlufiDelegate {
    func blufi(_ client: BlufiClient, gattPrepared status: BlufiStatusCode, service: CBService?, writeChar: CBCharacteristic?, notifyChar: CBCharacteristic?) {
        if status == StatusSuccess {
            isConnected = true
            updateMessage("BluFi connection has prepared")
        } else {
            blufiClient?.close()
            if service == nil {
                updateMessage("Discovering services failed")
            }
            if writeChar == nil {
                updateMessage("Discovering write char failed")
            }
            if notifyChar == nil {
                updateMessage("Discovering notify char failed")
            }
        }
    }

    func blufi(_ client: BlufiClient, didPostConfigureParams status: BlufiStatusCode) {
        if status == StatusSuccess {
            updateMessage("Post configure params complete")
        } else {
            updateMessage("Post configure params failed: \(status)")
        }
    }

    func blufi(_ client: BlufiClient, didReceiveDeviceStatusResponse response: BlufiStatusResponse?, status: BlufiStatusCode) {
        if status == StatusSuccess, response != nil {
            updateMessage("Receive device status:\n\(response!.getStatusInfo())")
        } else {
            updateMessage("Receive device status error: \(status)")
        }
    }

//    func blufi(_ client: BlufiClient, didReceiveDeviceScanResponse scanResults: [BlufiScanResponse]?, status: BlufiStatusCode) {
//        if status == StatusSuccess {
//            var info = String()
//            info.append(contentsOf: "Receive device scan results:\n")
//
//            for response in scanResults ?? [] {
//                info.append(contentsOf: "SSID: \(response.ssid), RSSI: \(response.rssi)\n")
//            }
//
//            updateMessage(info)
//        } else {
//            updateMessage("Receive device scan results error: \(status)")
//        }
//    }
}

// MARK: - ConfigureParamsDelegate
extension DetailViewController: ConfigureParamsDelegate {
    func didSetParams(params: BlufiConfigureParams) {
        blufiClient?.configure(params)
    }
}

// MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
}
