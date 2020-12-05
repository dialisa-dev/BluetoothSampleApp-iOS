//
//  ViewController.swift
//  BluetoothTest2
//
//  Created by Darren Muliawan on 8/26/20.
//  Copyright © 2020 Darren Muliawan. All rights reserved.
//

import UIKit
import CoreBluetooth
import DanaviBluetoothManager

class ViewController: UIViewController {
    var bluetoothManager = BluetoothManager()
    var discoveredMac: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothManager.events.listenTo(eventName: EVENT_BLUETOOTH_DANAVI, action: self.onReceiveEvent)
        bluetoothManager.enableBluetoothLogging()
    }
    
    // WRAPPER FUNCTION TO HANDLE ALL EVENTS SENT FROM BLUETOOTH MANAGER
    func onReceiveEvent(information: Any?) {
        let info = information as! EmittedEvent
        if (info.action == ACTION_BLUETOOTH_STATE_CHANGE) {
            print("\n\(info)")
            onBluetoothStateChange(event: info)
        } else if (info.action == ACTION_DEVICE_DISCOVERED) {
            print("\n\(info)")
            onDeviceDiscovered(event: info)
        } else if (info.action == ACTION_SCAN_FINISHED) {
            print("\n\(info)")
            onScanFinished(event: info)
        } else if (info.action == ACTION_DEVICE_CONNECTED) {
            print("\n\(info)")
            onDeviceConnected(event: info)
        } else if (info.action == ACTION_DEVICE_DISCONNECTED) {
            print("\n\(info)")
            onDeviceDisconnected(event: info)
        } else if (info.action == ACTION_DEVICE_FAILED_TO_CONNECT) {
            print("\n\(info)")
            onDeviceFailedToConnect(event: info)
        } else if (info.action == ACTION_DANAVI_THERMOMETER_MEASUREMENT) {
            print("\n\(info)")
            handleReceiveTemperatureMeasurement(event: info)
        } else if (info.action == ACTION_DEVICE_READY_TO_TAKE_MEASUREMENT) {
            print("\n\(info)")
            handleReadyTakeMeasurement()
        } else if (info.action == ACTION_OXIMETER_LIVE_DATA) {
            print("\n\(info)")
            handleReceiveOximeterMeasurement(event: info)
        } else if (info.action == ACTION_OXIMETER_TIMER) {
            //print("\n\(info)")
            handleOximeterTimer(event: info)
        } else if (info.action == ACTION_OXIMETER_MEASUREMENT_DONE) {
            print("\n\(info)")
            handleOximeterMeasurementDone()
        }
    }
    
    // FUNCTION TO HANDLE BLUETOOTH STATE CHANGE
    func onBluetoothStateChange(event: EmittedEvent) {
        if (event.value as! String == "PoweredOn") {
            // IF BLUETOOTH STATE IS POWERED ON, THEN READY TO SCAN DEVICES
            //bluetoothManager.scanDevices(deviceType: DANAVI_EAR_THERMOMETER_TYPE, timeout: 5.0)
            bluetoothManager.scanDevices(deviceType: DANAVI_OXIMETER_TYPE, timeout: 5.0)
        } else {
            // NEED TO HANDLE -- BLUETOOTH STATE IS NOT ON
        }
    }
    
    func onDeviceDiscovered(event: EmittedEvent) {
        // IF DEVICE IS DISCOVERED, APPEND MAC ADDRESS TO ARRAY
        self.discoveredMac.append(event.mac)
    }
    
    func onScanFinished(event: EmittedEvent) {
        // BLUETOOTH SCANNING HAS FINISHED
        if (self.discoveredMac.count == 1) {
            // ONLY 1 DEVICE FOUND, ATTEMPT TO CONNECT RIGHT AWAY
            bluetoothManager.connectDevice(mac: self.discoveredMac[0])
        } else if (self.discoveredMac.count == 0) {
            // NEED TO HANDLE -- NO DEVICE FOUND
        } else {
            // IF MORE THAN 1 DEVICE FOUND, PROMPT USER TO CHOOSE DEVICE
        }
    }
    
    func onDeviceConnected(event: EmittedEvent) {
        // IF DEVICE IS CONNECTED, THEN START MEASUREMENT
        if (event.deviceType == DANAVI_EAR_THERMOMETER_TYPE) {
            bluetoothManager.startDanaviThermometerMeasurement()
            //bluetoothManager.disconnectDevice(mac: event.mac)
        } else if (event.deviceType == DANAVI_OXIMETER_TYPE) {
            bluetoothManager.startDanaviOximeterMeasurement(writeToFile: true, withTimer: true, measurementLength: 10, thinningInterval: 20)
        }
    }
    
    func onDeviceDisconnected(event: EmittedEvent) {
        // TODO: UPDATE UI
    }
    
    func onDeviceFailedToConnect(event: EmittedEvent) {
        // TODO: UPDATE UI
    }
    
    func handleReceiveTemperatureMeasurement(event: EmittedEvent) {
        // GET TEMPERATURE OBJECT
        let measurement = event.value as! Temperature
        print("Temperature: \(measurement.temperature) \(measurement.unit)")
        
        // UPDATE UI
    }
    
    func handleReceiveOximeterMeasurement(event: EmittedEvent) {
        // GET OXIMETER MEASUREMENT OBJECT
        let measurement = event.value as! OximeterMeasurement
        print("Blood Oxygen: \(measurement.bloodOxygen), Heart Rate: \(measurement.heartRate), Pi: \(measurement.pi)")
        
        // UPDATE UI
    }
    
    func handleReadyTakeMeasurement() {
        // UPDATE UI TO PROMPT USER TO USE DEVICE
    }
    
    func handleOximeterTimer(event: EmittedEvent) {
        // UPDATE UI TO SHOW THE OXIMETER MEASUREMENT REMAINING TIME
        let remainingTime = event.value
        print(remainingTime)
    }
    
    func handleOximeterMeasurementDone() {
        // UPDATE UI
        // PROMPT USER THAT THEY HAVE FINISHED THE MEASUREMENT
        let data = bluetoothManager.retrieveOximeterData().split(whereSeparator: \.isNewline)
        print("Total recorded measurement: \(data.count)\n\(data)")
    }
}
