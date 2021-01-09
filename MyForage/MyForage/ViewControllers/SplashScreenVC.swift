//
//  SplashScreenVC.swift
//  MyForage
//
//  Created by Zachary Thacker on 1/7/21.
//

import SwiftUI

struct SplashScreen: View {
    static var shouldAnimate = true
    var tanColor = Color("TanColor")
    let oLineWidth: CGFloat = 5
    let oZoomFactor: CGFloat = 1.4
    let mushroomStemHeight:  CGFloat = 4
    let mushroomStemWidth: CGFloat = 27
    let mushroomCapLength: CGFloat = 21
    let black = Color("CharcoalColor")
    
    @State var mushroomOpasity: Double = 0
    @State var percent = 0.0
    @State var oScale: CGFloat = 1
    @State var mushroomColor = Color("CharcoalColor")
    @State var mushroomScale: CGFloat = 1
    @State var mushroomStemScale: CGFloat = 1
    @State var textAlpha = 0.0
    @State var textScale: CGFloat = 1
    @State var coverCircleScale: CGFloat = 1
    @State var coverCircleAlpha = 0.0
    
    var body: some View {
        ZStack {
            
            Image("pattern")
                .resizable(resizingMode: .tile)
                .opacity(textAlpha)
                .scaleEffect(textScale)
            
            
            Circle()
                .fill(tanColor)
                .frame(width: 1, height: 1,
                       alignment: .center)
                .scaleEffect(coverCircleScale)
                .opacity(coverCircleAlpha)
            
            
            Text("    F        RAGE")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .offset(x: 20,
                        y: 0)
                .scaleEffect(textScale)
            Text("MY")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .offset(x: -56,
                        y: -40)
                .scaleEffect(textScale)
            
            ForageO(percent: percent)
                .stroke(self.black, lineWidth: oLineWidth)
                .rotationEffect(.degrees(-90))
                .aspectRatio(1, contentMode: .fit)
                .padding(20)
                .onAppear() {
                    self.handleAnimations()
                }
                .scaleEffect(oScale * oZoomFactor)
                .frame(width: 45, height: 45,
                       alignment: .center)
            
            Ellipse()
                .fill(mushroomColor)
                .scaleEffect(mushroomScale * oZoomFactor)
                .frame(width: mushroomCapLength, height: mushroomCapLength/1.3,
                       alignment: .center)
                .offset(x: 0, y: -2)
                .onAppear() {
                    self.mushroomColor = self.tanColor
                }
            
            Rectangle()
                .fill(tanColor)
                .scaleEffect(mushroomStemScale * oZoomFactor)
                .frame(width: mushroomStemHeight * 1.5, height: mushroomStemHeight ,
                       alignment: .center)
                .offset(x: 0, y: 13)
                .onAppear() {
                    self.mushroomColor = self.tanColor
                }
    
            
            Image("Mushroom")
                .resizable(resizingMode: .stretch)
                .opacity(mushroomOpasity)
                .frame(width: 45, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            Image(systemName: "circle").font(.system(size: 55, weight: .semibold))
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .opacity(mushroomOpasity)
            
            
            Spacer()
        }
        .background(tanColor)
        .edgesIgnoringSafeArea(.all)
    }
}

extension SplashScreen {
    var oAnimationDuration: Double { return 1.4 }
    var oAnimationDelay: Double { return  0.2 }
    var oExitAnimationDuration: Double { return 0.3 }
    var finalAnimationDuration: Double { return 0.4 }
    var minAnimationInterval: Double { return 0.1 }
    var fadeAnimationDuration: Double { return 0.6 }
    
    func handleAnimations() {
        runAnimationPart1()
        runAnimationPart2()
        runAnimationPart3()
    }
    
    func runAnimationPart1() {
        withAnimation(.easeIn(duration: oAnimationDuration)) {
            percent = 1
            oScale = 4
            mushroomStemScale = 1
        }
        
        withAnimation(Animation.easeIn(duration: oAnimationDuration).delay(0.5)) {
            textAlpha = 1.0
        }
        
        let deadline: DispatchTime = .now() + oAnimationDuration + oAnimationDelay
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            withAnimation(.easeOut(duration: self.oExitAnimationDuration)) {
                self.oScale = 0
                self.mushroomStemScale = 0
            }
            withAnimation(.easeOut(duration: self.minAnimationInterval)) {
                self.mushroomScale = 0
            }
            
            withAnimation(Animation.spring()) {
                self.textScale = self.oZoomFactor
            }
        }
    }
    
    func runAnimationPart2() {
        let deadline: DispatchTime = .now() + oAnimationDuration + oAnimationDelay + minAnimationInterval
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.mushroomColor = Color.clear
            self.mushroomScale = 1
            
            withAnimation(.easeOut(duration: self.fadeAnimationDuration)) {
                self.coverCircleAlpha = 1
                self.coverCircleScale = 1000
                self.mushroomOpasity = 0.9
            }
        }
    }
    
    func runAnimationPart3() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2*oAnimationDuration) {
            withAnimation(.easeIn(duration: self.finalAnimationDuration)) {
                self.textAlpha = 0
                self.mushroomColor = self.tanColor
            }
        }
    }

}

struct ForageO: Shape {
    var percent: Double
    
    func path(in rect: CGRect) -> Path {
        let end = percent * 360
        var p = Path()
        
        p.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.width/2),
                 radius: rect.size.width/2,
                 startAngle: Angle(degrees: 0),
                 endAngle: Angle(degrees: end),
                 clockwise: false)
        
        return p
    }
    
    var animatableData: Double {
        get { return percent }
        set { percent = newValue }
    }
}

#if DEBUG
struct SplashScreen_Previews : PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
#endif
