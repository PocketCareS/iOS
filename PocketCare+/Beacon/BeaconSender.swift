import Foundation
import CoreLocation
import CoreBluetooth

public class BeaconSender: NSObject {
    
    public static let sharedInstance = BeaconSender()
    
    fileprivate var _region: CLBeaconRegion?
    fileprivate var _peripheralManager: CBPeripheralManager!
    
    fileprivate var _uuid = ""
    fileprivate var _identifier = ""
    
    
    public func startSending(uuid: String, majorID: CLBeaconMajorValue, minorID: CLBeaconMinorValue, identifier: String) {
        
        _uuid = uuid
        _identifier = identifier
        
        // create the region that will be used to send
        _region = CLBeaconRegion(uuid: UUID(uuidString: uuid)!, major: majorID, minor: minorID, identifier: identifier)
        _peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    open func stopSending() {
        _peripheralManager?.stopAdvertising()
    }
    
    open func isAdvertising() -> Bool{
        return _peripheralManager.isAdvertising
    }
    
}

//MARK: - CBPeripheralManagerDelegate

extension BeaconSender: CBPeripheralManagerDelegate {
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            
            let data = ((_region?.peripheralData(withMeasuredPower: nil))! as NSDictionary) as! Dictionary<String, Any>
            peripheral.startAdvertising(data)
            print("Powered On -> start advertising")
        }
        else if peripheral.state == .poweredOff {
            peripheral.stopAdvertising()
            print("Powered Off -> stop advertising")
        }
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Error starting advertising: \(error)")
        }
        else {
            print("Did start advertising")
        }
    }
}
