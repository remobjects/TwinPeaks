public class TPSmoothRotationTableViewController : UITableViewController { 
	private var frameBeforeRotation: CGRect!
	private var frameAfterRotation: CGRect!
	private var snapshotBeforeRotation: UIImageView!
	private var snapshotAfterRotation: UIImageView!

	private func captureSnapshotOfView(targetView: UIView!) -> UIImageView! {
		UIGraphicsBeginImageContextWithOptions(targetView.bounds().size, true, 0)
		CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -targetView.bounds().origin.x, -targetView.bounds().origin.y)
		targetView.layer().renderInContext(UIGraphicsGetCurrentContext())
		var image: UIImage! = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		var snapshowView: UIImageView! = UIImageView.alloc().initWithImage(image)
		snapshowView.setFrame(targetView.frame())
		return snapshowView
	}

	private func frame(frame: CGRect, withHeightFromFrame heightFrame: CGRect) -> CGRect! {
		frame.size.height = heightFrame.size.height
		return frame
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		tableView.reloadData()
	}
	
	override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration duration: NSTimeInterval) {
		tableView.reloadData()
		//frameBeforeRotation = tableView.frame
		//snapshotBeforeRotation = captureSnapshotOfView(tableView)
		//view().superview().insertSubview(snapshotBeforeRotation, aboveSubview: tableView)
	}
/*
	private func edgeInsetsForSmoothRotationWithWidth(width: CGFloat!) -> UIEdgeInsets! {
		return UIEdgeInsetsMake(0, width / 2, 0, width / 2)
	}

	private func edgeInsetsForSmoothRotation() -> UIEdgeInsets! {
		return edgeInsetsForSmoothRotationWithWidth(MIN(frameBeforeRotation.size.width, frameBeforeRotation.size.width))
	}

	private func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation!, duration duration: NSTimeInterval!) {
		frameAfterRotation = tableView.frame()
		UIView.setAnimationsEnabled(false)
		tableView.setNeedsLayout()
		tableView.setNeedsUpdateConstraints()
		tableView.setNeedsDisplay()
		tableView.reloadData()
		snapshotBeforeRotation.setFrame(frameBeforeRotation)
		snapshotAfterRotation = captureSnapshotOfView(tableView)
		snapshotAfterRotation.setFrame(frame(frameBeforeRotation, withHeightFromFrame: snapshotAfterRotation.frame()))
		tableView.setHidden(true)
		var imageBeforeRotation: UIImage! = snapshotBeforeRotation.image()
		var imageAfterRotation: UIImage! = snapshotAfterRotation.image()
		if imageBeforeRotation.respondsToSelector("resizableImageWithCapInsets") {
			var unstretchedAea: UIEdgeInsets! = edgeInsetsForSmoothRotation()
			imageBeforeRotation = imageBeforeRotation.resizableImageWithCapInsets(unstretchedAea, resizingMode: UIImageResizingModeTile)
			imageAfterRotation = imageAfterRotation.resizableImageWithCapInsets(unstretchedAea, resizingMode: UIImageResizingModeTile)
			snapshotBeforeRotation.setImage(imageBeforeRotation)
			snapshotAfterRotation.setImage(imageAfterRotation)
		}
		UIView.setAnimationsEnabled(true)
		if imageAfterRotation.size().height < imageBeforeRotation.size().height {
			snapshotAfterRotation.setAlpha(0)
			view().superview().insertSubview(snapshotAfterRotation, aboveSubview: snapshotBeforeRotation)
			snapshotAfterRotation.setAlpha(1)
		} else {
			view().superview().insertSubview(snapshotAfterRotation, belowSubview: snapshotBeforeRotation)
			snapshotBeforeRotation.setAlpha(0)
		}
		snapshotAfterRotation.setFrame(frameAfterRotation)
		snapshotBeforeRotation.setFrame(frame(frameAfterRotation, withHeightFromFrame: snapshotBeforeRotation.frame()))
	}

	private func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation!) {
		snapshotBeforeRotation.removeFromSuperview()
		snapshotAfterRotation.removeFromSuperview()
		snapshotBeforeRotation = nil
		snapshotAfterRotation = nil
		tableView.setHidden(false)
	}
	*/
}

