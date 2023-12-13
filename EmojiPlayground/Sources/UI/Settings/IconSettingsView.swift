//
//  IconSettingsView.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2023/06/12.
//

/*
 How to add App Icon
  1. Add Assets AppIcon and Image
  2. Add Alternate App Icon Set of Build Settings
 */

import SwiftUI

struct IconSettingsView: View {
    @State private var currentIcon = UIApplication.shared.alternateIconName ?? Icon.main.appIconName
    
    private let columns = [GridItem(.adaptive(minimum: 125, maximum: 1024))]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                makeIconGridView(icons: Icon.allCases)
//                ForEach(IconSelector.items) { item in
//                    Section {
//                        makeIconGridView(icons: item.icons)
//                    } header: {
//                        Text(item.title)
//                            .font(.headline)
//                    }
//                }
            }
            .padding()
        }
        .navigationTitle("앱 아이콘")
    }
    
    private func makeIconGridView(icons: [Icon]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(icons) { icon in
                Button {
                    currentIcon = icon.appIconName
                    if icon.rawValue == Icon.main.rawValue {
                        UIApplication.shared.setAlternateIconName(nil)
                    } else {
                        UIApplication.shared.setAlternateIconName(icon.appIconName) { err in
                            guard let err else { return }
                            assertionFailure("\(err.localizedDescription) - Icon name: \(icon.appIconName)")
                        }
                    }
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: .init(named: icon.iconName) ?? .init())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minHeight: 125, maxHeight: 1024)
                            .clipShape(.rect(cornerRadius: 4))
                            .shadow(radius: 3)
                        
                        if icon.appIconName == currentIcon {
                            Image(systemName: "checkmark.seal.fill")
                                .padding(4)
                                .tint(.green)
                        }
                    }
                }
            }
        }
    }
}

extension IconSettingsView {
    enum Icon: Int, CaseIterable, Identifiable {
        case main = 0
        case alt1
        case alt2
        case alt3
        case alt4
        
        init(string: String?) {
            guard let string else {
                self = .main
                return
            }
            
            if string == Icon.main.appIconName {
                self = .main
            } else {
                self = .init(rawValue: Int(String(string.replacing("AppIconAlternate", with: "")))!)!
            }
        }
        
        var id: Int { rawValue }
        
        var appIconName: String {
            if self == .main {
                return "AppIcon"
            } else {
                return "AppIconAlternate\(rawValue)"
            }
        }
        
        var iconName: String {
            "icon\(rawValue)"
        }
    }
}

extension IconSettingsView {
    struct IconSelector: Identifiable {
        let id = UUID()
        let title: String
        let icons: [Icon]
        
        static let items = [
            IconSelector(title: "공식 아이콘", icons: Icon.allCases),
            IconSelector(title: "기타", icons: [])
        ]
    }
}

struct IconSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        IconSettingsView()
    }
}
