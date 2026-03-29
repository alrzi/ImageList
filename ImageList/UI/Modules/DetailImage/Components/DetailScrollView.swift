//
//  DetailScrollView.swift
//  ImageList
//
//  Created by Александр Зиновьев on 10.03.2023.
//

import UIKit

final class DetailScrollView: UIScrollView {
    private var imageView: UIImageView?

    private lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        delegate = self
        minimumZoomScale = 0.1
        maximumZoomScale = 0.7
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        contentInsetAdjustmentBehavior = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    @objc
    func doubleTapAction(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: recognizer.view)
        let zoomRect = calculateZoomRect(at: point)

        self.zoom(to: zoomRect, animated: true)
    }
}

extension DetailScrollView {
    func setImageView(_ imageView: UIImageView) {
        self.imageView = imageView

        addSubview(imageView)
        self.imageView?.addGestureRecognizer(zoomingTap)
        self.imageView?.isUserInteractionEnabled = true
    }

    func calculateZoomRect(at touchPoint: CGPoint) -> CGRect {
        let scale = maximumZoomScale

        let zoomWidth = contentSize.width / scale
        let zoomHeight = contentSize.height / scale

        let halfWidth = zoomWidth / 2
        let halfHeight = zoomHeight / 2

        return CGRect(x: touchPoint.x - halfWidth, y: touchPoint.y - halfHeight, width: zoomWidth, height: zoomHeight)
    }

    func centerImageAfterZooming() {
        let contentWidth = self.contentSize.width
        let contentHeight = self.contentSize.height
        let scrollWidth = self.bounds.width
        let scrollHeight = self.bounds.height
        let hPadding = contentWidth < scrollWidth ? (scrollWidth - contentWidth) / 2 : 0
        let vPadding = contentHeight < scrollHeight ? (scrollHeight - contentHeight) / 2 : 0

        self.contentInset = UIEdgeInsets(top: vPadding, left: hPadding, bottom: vPadding, right: hPadding)
    }

    func rescaleImage() {
        let visibleRectSize = self.bounds.size
        let imageSize = self.contentSize
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height

        let theoreticalScale = max(hScale, vScale)
        let finalScale = theoreticalScale.clamped(to: minimumZoomScale...maximumZoomScale)

        self.setZoomScale(finalScale, animated: false)
    }

    func centerImage() {
        let newContentsSize = self.contentSize
        let visibleRectSize = self.bounds.size
        let x = (newContentsSize.width - visibleRectSize.width) / 2
        let y = (newContentsSize.height - visibleRectSize.height) / 2

        self.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate

extension DetailScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageAfterZooming()
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
