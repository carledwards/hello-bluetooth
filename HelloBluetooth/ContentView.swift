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
    simpleBluetoothIO.writeValue(value: remoteTurnOn ? 1 : 0)
  }

  func remoteValueChanged(_ value: Int8) -> Void {
      self.bluetoothDevice.remoteValue = Int(value)
  }
  
  init() {
    simpleBluetoothIO = SimpleBluetoothIO(serviceUUID: "31423931", onValueChanged: remoteValueChanged)
  }
  
  var body: some View {
    let remoteOn = Binding<Bool>(get: { self.remoteTurnOn }, set: { self.remoteTurnOn = $0; self.sendRemoteValue()})

    return NavigationView {
      Form {
        Section {
          Toggle(isOn: remoteOn) {
            Text("Set remote value \(remoteTurnOn.description)")
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
