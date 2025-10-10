+++
date = '2025-09-26T12:50:12+08:00'
draft = false 
title = 'Class01 - Text,Image,Stack,Button & State'
tags = ['Text', 'Image', 'Stack', 'Button']
isCJKLanguage = true
+++

## 技術覆蓋
- Text
- Image
- Stack
- Button
## Text 組件
### 1. 輸出文字
```swift
// 輸出 example
Text("example")
// 輸出 Hello, World!
Text("Hello, World!")
```
### 2. 更換字體顏色
```swift
// White
Text("example").foregroundColor(.white)
// Red
Text("example").foregroundColor(.red)
```
### 3. 更換字體大小
```swift
// Size: 25
Text("example").font(.system(size: 25))
// Size: 50
Text("example").font(.system(size: 50))
```
### 4. 粗體
```swift
Text("example").bold()
```
### 5. 斜體
```swift
Text("example").italic()
```
## Image 組件
### 1. 顯示系統提供圖標
```swift
// 顯示person圖標
Image(systemName: "person")
// 顯示person圖標, fill樣式
Image(systemName: "person.fill")
// 顯示person圖標, outline樣式
Image(systemName: "person.outline")
```
#### 1.1 更換系統圖標顏色
```swift
// Green
Image(systemName: "person.fill").foregroundColor(.green)
// Red
Image(systemName: "person.fill").foregroundColor(.red)
```
### 2. 顯示自己本地圖片
> 使用swift playground載入圖片之後，需要確認圖片名稱跟代碼上寫的名稱一致
```swift
Image("<本地圖片檔案名稱>")
```
### 3. 設置圖片大小
```swift
// 高度150，寬度150
Image(systemName: "person")
    .resizable()
    .frame(width: 150.0, height: 150.0)
// 高度200，寬度150
Image(systemName: "person")
    .resizable()
    .frame(width: 150.0, height: 200.0)
```
### 4. 設置圖片大小直接填滿畫面
```swift
Image(systemName: "person.fill")
    .resizable()
    .aspectRatio(contentMode: .fit)
```
### 5. 圖片剪裁成圓形
```swift
Image(systemName: "person.fill")
    .clipShape(Circle())
```
#### 5.1 加上圓形外框(border)
```swift
// White
Image(systemName: "person.fill")
    .clipShape(Circle())
    .overlay(Circle().stroke(.white, lineWidth: 5))
// Red
Image(systemName: "person.fill")
    .clipShape(Circle())
    .overlay(Circle().stroke(.red, lineWidth: 5))
```
## Stack 組件
Stack組件存在的目的就是為了**佈局**。  
撰寫的時候只要去思考到底是以下何種佈局方式:
- 從`上`到`下` 
- 從`左`到`右`
- 從`後`到`前`
#### 1. VStack (從`上`到`下`)
```swift
VStack {
    Text("Item 01")
    Text("Item 02")
    Text("Item 03")
}
```
#### 2. HStack (從`左`到`右`)
```swift
HStack {
    Text("Item 01")
    Text("Item 02")
    Text("Item 03")
}
```
#### 3. ZStack (從`後`到`前`)
> 通常是拿來加背景
```swift
ZStack {
    // 加上綠色背景
    Color(.green)
        .edgesIgnoringSafeArea(.all)
    VStack {
        Text("Item 01")
        Text("Item 02")
        Text("Item 03")
    }
}
```
## Button 組件
`Button`就是按鈕，按鈕的主要目的就是**執行操作**  
撰寫的時候主要思考以下兩件事:
- 執行什麼?
- 長什麼樣?
### 1. Button 組件代碼結構
```swift
    Button {
        // 填入按鈕點擊後要執行的代碼
    } label: {
        // 按鈕應該長什麼樣子
    }
```
### 2. 文字按紐
> 在Text組件教的寫法，可以直接填入`label`代碼塊中
```swift
    Button {
        // 填入按鈕點擊後要執行的代碼
    } label: {
        // 按鈕應該長什麼樣子
        Text("example").foregroundColor(.red)
    }
```
### 3. 圖片按紐
> 在Image組件教的寫法，可以直接填入`label`代碼塊中
```swift
    Button {
        // 填入按鈕點擊後要執行的代碼
    } label: {
        // 按鈕應該長什麼樣子
        Image(systemName: "person.fill")
            .clipShape(Circle())
            .overlay(Circle().stroke(.red, lineWidth: 5))
    }
```
## Code 範例
### 個人名片
![img](https://fussel.ygfrds.sbs/static/_gallery/albums/album01/488x887_screenshot-2025-09-26-at-12-39-14-png.png)
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
