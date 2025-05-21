//
//  ContentView.swift
//  Mystic-Puzzle
//
//  Created by Ronjie Diafante Man-on on 5/21/25.
//

import SwiftUI

struct MainView: View {
    var mysticPuzzleViewModel: MysticPuzzleViewModel = MysticPuzzleViewModel()
    
    let title = "Mystic Puzzle"
    let newGamePrompt = "New Game"
    let shufflePrompt = "Shuffle"
    let goalPrompt = "Easy Game"
    let tileDimensions: CGFloat = 70
    let speakerDimensions: CGFloat = 40
    
    @State var volume: Float = 1.0
    
    @State private var moveCount = 0
    
    var body: some View {
        VStack {
            
            ChalkboardTextView(text: title, size: 42, color: .white)
            
            puzzleBoard
            
            buttons
            
            HStack(spacing: 20) {
                
                Slider(value: $volume, in: 0...1)
                
                Button {
                    volume = volume > 0 ? 0 : 1
                } label: {
                    Image(systemName: volume > 0 ? "speaker" : "speaker.slash")
                        .resizable()
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: speakerDimensions, height: speakerDimensions)
                }
            }
            .padding()
            .padding(.vertical)
        }
        .background(Image("WaterBackground"))
    }
}

struct ChalkboardTextView: View {
    let text: String
    let size: CGFloat
    let color: Color
    var body: some View {
        Text( text)
            .font(Font.custom( "ChalkboardSE-Bold", size: size))
            .fontWeight(.bold)
            .foregroundColor( color)
            .shadow(color: color, radius: 1)
    }
}

struct TileView: View {
    let tileNumber: Int
    let tileDimensions: CGFloat
    let offset: CGPoint
    
    let digitResizeFactor: CGFloat = 2/5
    
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        let direction = offset * tileDimensions
        
        let deltaX = direction.x + tileDimensions / 2
        let deltaY = direction.y - 3 * tileDimensions / 2
        
        let somePadding: CGFloat = 3
        
        Image("digit\(tileNumber)")
            .resizable()
            .renderingMode( .template)
            .foregroundColor( .red)
            .aspectRatio(contentMode: .fit)
            .frame(
                width: tileDimensions*digitResizeFactor,
                height: tileDimensions*digitResizeFactor)
            .scaleEffect(tileNumber < 10 ? 1 : 1.4)
            .background(
                Image("MarbleTileBackground")
                    .resizable()
                    .opacity( 0.9)
                    .frame(
                        width: tileDimensions - somePadding,
                        height: tileDimensions - somePadding
                    )
                    .cornerRadius( 10)
            )
            .padding()
            .offset(
                x: deltaX+dragOffset.width,
                y: deltaY+dragOffset.height
            )
            .shadow(color: .black, radius: 1, x: 1, y: 1)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        print("Dragging")
                        dragOffset = gesture.translation
                    }
                    .onEnded { _ in
                        withAnimation {
                            dragOffset = .zero
                        }
                    }
            )
    }
}


extension MainView {
    private var buttons: some View {
        HStack {
            Button(action: {
                mysticPuzzleViewModel.createInitialItems()
                mysticPuzzleViewModel.shuffle()
            }) {
                ChalkboardTextView(
                    text: mysticPuzzleViewModel.done() ? newGamePrompt : shufflePrompt,
                    size: 24,
                    color: .yellow
                )
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.yellow, lineWidth: 3)
                )
                .padding(.vertical)
                .animation(.easeInOut, value: mysticPuzzleViewModel.done())
            }
            
            Button {
                mysticPuzzleViewModel.createInitialItems()
            } label: {
                ChalkboardTextView(
                    text: goalPrompt,
                    size: 24,
                    color: .green
                )
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.green, lineWidth: 3)
                )
                .padding(.vertical)
            }
        }
    }
}

extension MainView {
    private var puzzleBoard: some View {
        ZStack {
            ForEach( 0..<mysticPuzzleViewModel.mysticPuzzleModel.tiles.count-1, id: \.self) { i in
                TileView(
                    tileNumber: mysticPuzzleViewModel.mysticPuzzleModel.tiles[i].value,
                    tileDimensions: tileDimensions,
                    offset: mysticPuzzleViewModel.mysticPuzzleModel.tiles[i].currentPoint
                )
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)){
                        if mysticPuzzleViewModel.move( index: i) {
                            moveCount += 1
                            print("\(moveCount) moves")
                            
                            playSound(
                                sound: "mixkit-glass-plate-slide-1527",
                                type: "wav",
                                volume: volume
                            )
                        }
                    }
                }
            }
        }
        .frame(
            maxWidth: tileDimensions * 4,
            maxHeight: tileDimensions * 4
        )
        .padding()
        .background(
            Image("BlueMarbleBackground")
                .resizable().opacity( 0.9)
        )
        .shadow(color: .black, radius: 10, x: 3, y: 3)
        .padding()
    }
}

#Preview {
    MainView()
}
