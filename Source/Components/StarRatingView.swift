//
//  StarRatingView.swift
//  vaela
//
//  Created by decoherence on 4/29/24.
//

import Foundation
import SwiftUI

struct RatingView: View {
    var rating: Double
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        HStack {
            ShapeForRating(rating: rating)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }

    @ViewBuilder
    private func ShapeForRating(rating: Double) -> some View {
        switch rating {
        case -1:
            Asterisk()
        case 0:
            Asterisk()
        case 1:
            Asterisk()
        default:
            Text("No stars")
        }
    }
}



struct Asterisk: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: width, y: 0.43127*height))
        path.addLine(to: CGPoint(x: 0.61922*width, y: 0.43127*height))
        path.addLine(to: CGPoint(x: 0.80988*width, y: 0.10159*height))
        path.addLine(to: CGPoint(x: 0.69082*width, y: 0.03278*height))
        path.addLine(to: CGPoint(x: 0.56873*width, y: 0.24378*height))
        path.addLine(to: CGPoint(x: 0.56873*width, y: 0))
        path.addLine(to: CGPoint(x: 0.43127*width, y: 0))
        path.addLine(to: CGPoint(x: 0.43127*width, y: 0.38086*height))
        path.addLine(to: CGPoint(x: 0.10159*width, y: 0.1902*height))
        path.addLine(to: CGPoint(x: 0.03278*width, y: 0.30918*height))
        path.addLine(to: CGPoint(x: 0.24378*width, y: 0.43127*height))
        path.addLine(to: CGPoint(x: 0, y: 0.43127*height))
        path.addLine(to: CGPoint(x: 0, y: 0.56873*height))
        path.addLine(to: CGPoint(x: 0.38086*width, y: 0.56873*height))
        path.addLine(to: CGPoint(x: 0.1902*width, y: 0.89841*height))
        path.addLine(to: CGPoint(x: 0.30918*width, y: 0.9673*height))
        path.addLine(to: CGPoint(x: 0.43127*width, y: 0.75623*height))
        path.addLine(to: CGPoint(x: 0.43127*width, y: height))
        path.addLine(to: CGPoint(x: 0.56873*width, y: height))
        path.addLine(to: CGPoint(x: 0.56873*width, y: 0.61922*height))
        path.addLine(to: CGPoint(x: 0.89841*width, y: 0.80988*height))
        path.addLine(to: CGPoint(x: 0.96729*width, y: 0.69082*height))
        path.addLine(to: CGPoint(x: 0.75623*width, y: 0.56873*height))
        path.addLine(to: CGPoint(x: width, y: 0.56873*height))
        path.addLine(to: CGPoint(x: width, y: 0.43127*height))
        path.closeSubpath()
        return path
    }
}
