import SwiftUI

struct ClientsRow: View {
    let client: Client
    
    var body: some View {
        HStack {
            Text("\(client.firstName)")
            Spacer()
            Text("\(client.phoneNumber)")
        }
    }
    
}
