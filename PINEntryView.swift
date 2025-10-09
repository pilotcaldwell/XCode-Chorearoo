import SwiftUI

struct PINEntryView: View {
    @Binding var pin: String
    let title: String
    let maxDigits: Int = 4
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            // PIN dots display
            HStack(spacing: 20) {
                ForEach(0..<maxDigits, id: \.self) { index in
                    Circle()
                        .fill(index < pin.count ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }
            .padding()
            
            // Number pad
            VStack(spacing: 15) {
                ForEach(0..<3) { row in
                    HStack(spacing: 15) {
                        ForEach(1..<4) { col in
                            let number = row * 3 + col
                            Button(action: {
                                addDigit(String(number))
                            }) {
                                Text("\(number)")
                                    .font(.title)
                                    .frame(width: 70, height: 70)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(35)
                            }
                        }
                    }
                }
                
                // Bottom row with 0 and delete
                HStack(spacing: 15) {
                    Button(action: {
                        // Empty space
                    }) {
                        Text("")
                            .font(.title)
                            .frame(width: 70, height: 70)
                    }
                    .disabled(true)
                    .opacity(0)
                    
                    Button(action: {
                        addDigit("0")
                    }) {
                        Text("0")
                            .font(.title)
                            .frame(width: 70, height: 70)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(35)
                    }
                    
                    Button(action: {
                        deleteDigit()
                    }) {
                        Image(systemName: "delete.left")
                            .font(.title2)
                            .frame(width: 70, height: 70)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(35)
                    }
                }
            }
        }
        .padding()
    }
    
    private func addDigit(_ digit: String) {
        if pin.count < maxDigits {
            pin += digit
        }
    }
    
    private func deleteDigit() {
        if !pin.isEmpty {
            pin.removeLast()
        }
    }
}

#Preview {
    PINEntryView(pin: .constant(""), title: "Enter PIN")
}
