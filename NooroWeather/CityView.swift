import SwiftUI

struct CityView: View {
    private let city: City
    
    init(city: City) {
        self.city = city
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(city.location.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Spacer()
                    .fixedSize()
                Text(String(city.temp))
                    .font(.system(size: 40, weight: .bold))
            }
            
            Spacer()
            
            AsyncImage(url: city.current.condition.iconUrl) { result in
                result.image?
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: 123, height: 113)
                
        }
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }
}
