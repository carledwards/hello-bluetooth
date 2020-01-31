import SwiftUI
import Combine

class BluetoothDevice : ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    
    @Published var remoteValue:Int
    
    init(remoteValue: Int) {
        self.remoteValue = remoteValue
    }
}

struct ContentView: View {
  @ObservedObject private var bluetoothDevice: BluetoothDevice = BluetoothDevice(remoteValue: 0)
  private var simpleBluetoothIO: SimpleBluetoothIO!
  
  @State private var remoteTurnOn: Bool = false
  
  func sendRemoteValue() -> Void {
    simpleBluetoothIO.writeString(value: remoteTurnOn ? "On" : "Off")
  }

  func remoteValueChanged(_ value: Int8) -> Void {
      self.bluetoothDevice.remoteValue = Int(value)
  }
  
  init() {
    simpleBluetoothIO = SimpleBluetoothIO(serviceUUID: "CA55E77E", onValueChanged: remoteValueChanged)
  }
  
  var body: some View {
    let remoteOn = Binding<Bool>(get: { self.remoteTurnOn }, set: { self.remoteTurnOn = $0; self.sendRemoteValue()})

    return NavigationView {
      Form {
        Section {
          Toggle(isOn: remoteOn) {
            Text("Set remote value")
          }
        }.padding()
        
        Section {
          Text("Remote value: \(bluetoothDevice.remoteValue)")
        }.padding()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
