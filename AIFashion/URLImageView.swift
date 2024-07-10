//
//  URLImageView.swift
//  AIFashion
//
//  Created by Aashish Dhanani on 7/10/24.
//

import SwiftUI

struct URLImageView: View {
   
   let url: URL
   
   var body: some View {
      AsyncImage(
         url: url,
         transaction: Transaction(animation: .easeInOut)
      ) { phase in
         switch phase {
         case .empty:
            ProgressView()
         case .success(let image):
            image
               .resizable()
               .frame(width: 100, height: 100)
               .transition(.opacity)
         case .failure:
            Image(systemName: "wifi.slash")
         @unknown default:
            EmptyView()
         }
      }
      .frame(width: 100, height: 100)
      .background(Color.gray)
      .clipShape(RoundedRectangle(cornerRadius: 10))
   }
}
let urlImageViewMockURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg")!


#Preview {
   
   ScrollView {
      VStack(spacing: 40) {
         URLImageView(url: urlImageViewMockURL)
         URLImageView(url: urlImageViewMockURL)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10)
         URLImageView(url: urlImageViewMockURL)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
      }
   }
}

