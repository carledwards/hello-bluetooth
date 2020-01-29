import CoreBluetooth

class SimpleBluetoothIO: NSObject {
  let serviceUUID: String
  var valueChangedDelegate: (Int8) -> Void
  
  var centralManager: CBCentralManager!
  var connectedPeripheral: CBPeripheral?
  var targetService: CBService?
  var writableCharacteristic: CBCharacteristic?
  
  init(serviceUUID: String, onValueChanged valueChangedDelegate: @escaping (_ value: Int8) -> Void) {
    self.serviceUUID = serviceUUID
    self.valueChangedDelegate = valueChangedDelegate
    
    super.init()
    
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func writeValue(value: Int8) {
    guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
      return
    }
    
    let data = Data.dataWithValue(value: value)
    peripheral.writeValue(data, for: characteristic, type: .withResponse)
  }
  
}

extension SimpleBluetoothIO: CBCentralManagerDelegate {
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.discoverServices(nil)
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    connectedPeripheral = peripheral

    if let connectedPeripheral = connectedPeripheral {
      print("connectedPeripheral.identifier.uuidString: \(connectedPeripheral.identifier.uuidString), name: \(connectedPeripheral.name)")
        connectedPeripheral.delegate = self
        centralManager.connect(connectedPeripheral, options: nil)
        centralManager.stopScan()
    }
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      centralManager.scanForPeripherals(withServices: [CBUUID(string: self.serviceUUID)], options:[
        CBCentralManagerScanOptionAllowDuplicatesKey:false,
      ])
    }
  }
}

extension SimpleBluetoothIO: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else {
      return
    }
    
    targetService = services.first
    if let service = services.first {
      targetService = service
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else {
      return
    }
    
    for characteristic in characteristics {
      if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
        writableCharacteristic = characteristic
      }
      peripheral.setNotifyValue(true, for: characteristic)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    guard let data = characteristic.value else {
      return
    }
    
    valueChangedDelegate(data.int8Value())
  }
}
