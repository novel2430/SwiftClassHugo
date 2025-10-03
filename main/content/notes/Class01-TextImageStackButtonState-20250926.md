+++
date = '2025-09-26T12:50:12+08:00'
draft = false 
title = 'Class01 - Text,Image,Stack,Button & State'
tags = ['Text', 'Image', 'Stack', 'Button']
isCJKLanguage = true
+++

## 基礎技術
- Text
- Image
- Stack
- Button
- State
## 基礎技術
### Code
```swift
import SwiftUI

struct ContentView: View {
    @State var currentBackgroundColor = Color(red: 0.09, green: 0.63, blue: 0.52)
    var body: some View {
        ZStack {
            currentBackgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: "person.fill")
                    .resizable()
                    //.aspectRatio(contentMode: .fit)
                    .frame(width: 150.0, height: 150.0)
                    .foregroundColor(.green)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 5))
                Text("Feng Yu Wei")
                    .font(.system(size: 40, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                Text("iOS Developer")
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .italic()
                InfoView(imageName: "phone.fill", text: "+86 18888988788")
                InfoView(imageName: "envelope.fill", text: "fengyuwei@zju.edu.cn")
                HStack {
                    Button {
                        currentBackgroundColor = Color.red
                    } label: {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundStyle(.red)
                    }
                    Button {
                        currentBackgroundColor = Color.blue
                    } label: {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundStyle(.blue)
                    }
                    Button {
                        currentBackgroundColor = Color(red: 0.09, green: 0.63, blue: 0.52)
                    } label: {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
    }
}

struct InfoView: View {
    let imageName: String
    let text: String
    var imageColor: Color? = .green
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.white)
            .frame(height: 50)
            .overlay(
                HStack {
                    Image(systemName: imageName)
                        .foregroundColor(imageColor)
                    Text(text)
                        .foregroundColor(.black)
                })
            .padding(.all)
    }
}
```
