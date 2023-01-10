//
//  CustomAnnotationView.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import Foundation
import MapKit
import SnapKit

final class CustomAnnotationView: MKMarkerAnnotationView {

    weak var calloutView: CalloutView?
    override var annotation: MKAnnotation? {
        willSet {
            calloutView?.removeFromSuperview()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.calloutView?.removeFromSuperview()
            guard let annotation = annotation as? CustomAnnotation else { return }
            let calloutView = CalloutView(annotation: annotation)
            addSubview(calloutView)
            calloutView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(75)
                make.centerX.equalToSuperview()
                make.width.equalTo(210)
                make.height.equalTo(140)
            }
            self.calloutView = calloutView
            if animated {
                calloutView.alpha = 0
                UIView.animate(withDuration: 0.25) {
                    calloutView.alpha = 1
                }
            }
        } else {
            guard let calloutView = calloutView else { return }
            if animated {
                UIView.animate(withDuration: 0.25, animations: {
                    calloutView.alpha = 0
                }, completion: { _ in
                    calloutView.removeFromSuperview()
                })
            } else {
                calloutView.removeFromSuperview()
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        calloutView?.removeFromSuperview()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let calloutView = calloutView {
            let pointInCalloutView = convert(point, to: calloutView)
            return calloutView.hitTest(pointInCalloutView, with: event)
        }
        return nil
    }
}
