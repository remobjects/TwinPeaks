using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	public interface ITPSplitViewDelegate
	{
		void splitViewDidResizeSubviews(TPSplitView splitView);
	}

	public class TPSplitView: NSSplitView, INSSplitViewDelegate
	{
		public override void awakeFromNib()
		{
			_priorityViewIndex = 1;
			_minTopLeft = 200;
			_minBottomRight = 200;
			_maxTopLeft = INT_MAX;
			_maxBottomRight = INT_MAX;
			//  divider style is thin by default
			setDividerStyle(NSSplitViewDividerStyle.NSSplitViewDividerStyleThin);
			//  create and adjust handle image
			handleImage = new NSImageView();
			handleImage.setImageAlignment(NSImageAlignCenter);
			handleImage.setImageScaling(NSImageScaleNone);
			NSImage i = NSImage.imageNamed("VerticalSplit");
			handleImage.setImage(i);
			this.setHandleOnRight(false);
			this.adjustSubviews();
			this.setDelegate(this);
		}

		private void setHandleOnRight(bool @value)
		{
			handleOnRight = @value;
			NSRect handleFrame = handleImage.frame();
			handleFrame.size.width = 20;
			handleFrame.size.height = 20;
			NSRect newBounds;
			newBounds.size.width = handleFrame.size.width;
			newBounds.size.height = handleFrame.size.height;
			if (handleOnRight)
			{
				NSView rightSubview = this.subviews().objectAtIndex(1);
				newBounds.origin.x = (newBounds.origin.y = 5);
				rightSubview.addSubview(handleImage);
				handleImage.setAutoresizingMask(NSViewMaxXMargin | NSViewMaxYMargin);
			}
			else
			{
				NSView leftSubview = this.subviews().objectAtIndex(0);
				NSRect leftFrame = leftSubview.frame();
				newBounds.origin.x = (leftFrame.size.width - handleFrame.size.width);
				newBounds.origin.y = 5;
				leftSubview.addSubview(handleImage);
				handleImage.setAutoresizingMask(NSViewMinXMargin | NSViewMaxYMargin);
			}
			newBounds.size.width = handleFrame.size.width;
			newBounds.size.height = handleFrame.size.height;
			handleImage.setFrame(newBounds);
		}

		public override bool mouseDownCanMoveWindow()
		{
			return true;
		}

		public override CGFloat dividerThickness()
		{
			return base.dividerThickness();
		}

		private bool splitView(NSSplitView splitView) shouldHideDividerAtIndex(NSInteger dividerIndex)
		{
			return this.secondaryViewIsHidden();
		}

		public override NSColor dividerColor()
		{
			return NSColor.darkGrayColor();
		}

		private CGFloat totalSize()
		{
			if (this.isVertical())
				return this.frame().size.width;
			else
				return this.frame().size.height;
		}

		private bool bottomRightHidden()
		{
			return (_priorityViewIndex == 0) && this.secondaryViewIsHidden();
		}

		private bool topLeftHidden()
		{
			return (_priorityViewIndex == 1) && this.secondaryViewIsHidden();
		}

		private NSRect splitView(NSSplitView splitView) additionalEffectiveRectOfDividerAtIndex(NSInteger dividerIndex)
		{
			return handleImage.convertRect(handleImage.bounds()) toView(this);
		}

		private CGFloat splitView(NSSplitView splitView) constrainSplitPosition(CGFloat proposedPosition) ofSubviewAt(NSInteger dividerIndex)
		{
			//  if (![self isVertical]) NSLog(@"constrainSplitPosition:%f ofSubviewAt:%ld", proposedPosition, dividerIndex);
			//  if (_priorityViewIndex == 1 && [self secondaryViewIsHidden]) return splitView.bounds.size.width;
			//  if (_priorityViewIndex == 0 && [self secondaryViewIsHidden]) return 0;
			if (proposedPosition < _minTopLeft)
				proposedPosition = _minTopLeft;
			if (proposedPosition > (this.totalSize() - _minBottomRight))
				proposedPosition = (this.totalSize() - _minBottomRight);
			if (proposedPosition > _maxTopLeft)
				proposedPosition = _maxTopLeft;
			if (proposedPosition < (this.totalSize() - _maxBottomRight))
				proposedPosition = (this.totalSize() - _maxBottomRight);
			return proposedPosition;
		}

		private CGFloat splitView(NSSplitView splitView) constrainMinCoordinate(CGFloat proposedMin) ofSubviewAt(NSInteger dividerIndex)
		{
			return _minTopLeft;
		}

		private CGFloat splitView(NSSplitView splitView) constrainMaxCoordinate(CGFloat proposedMax) ofSubviewAt(NSInteger dividerIndex)
		{
			return this.totalSize() - _minBottomRight;
		}

		private void splitView(NSSplitView splitView) resizeSubviewsWithOldSize(NSSize oldSize)
		{
			NSArray subviews = splitView.subviews();
			bool isVertical = splitView.isVertical();
			if (this.bottomRightHidden())
			{
				CGSize size0 = this.frame().size;
				CGSize size1 = this.frame().size;
				if (isVertical)
				{
					size0.width--;
					size1.width = 1;
				}
				else
				{
					size0.height--;
					size1.height = 1;
				}
				subviews.objectAtIndex(0).setFrameSize(size0);
				subviews.objectAtIndex(1).setFrameSize(size1);
				return;
			}
			if (this.topLeftHidden())
			{
				subviews.objectAtIndex(1).setFrameSize(this.frame().size);
				subviews.objectAtIndex(0).setFrameSize(NSZeroSize);
				return;
			}
			CGFloat delta = isVertical ? splitView.bounds.size.width - oldSize.width : splitView.bounds.size.height - oldSize.height;
			int start = _priorityViewIndex == 1 ? 1 : 0;
			int end = _priorityViewIndex == 1 ? -1 : 2;
			int direction = _priorityViewIndex == 1 ? -1 : 1;
			for (int i = start; i != end; i += direction)
			{
				NSView view = subviews.objectAtIndex(i);
				NSSize frameSize = view.frame().size;
				CGFloat size;
				if (isVertical)
				{
					frameSize.height = splitView.bounds.size.height;
					size = frameSize.width;
				}
				else
				{
					frameSize.width = splitView.bounds.size.width;
					size = frameSize.height;
				}
				CGFloat minLengthValue = i == 0 ? _minTopLeft : _minBottomRight;
				if ((delta > 0) || ((size + delta) >= minLengthValue))
				{
					size += delta;
					delta = 0;
				}
				else
					if (delta < 0)
					{
						delta += (size - minLengthValue);
						size = minLengthValue;
					}
				if (isVertical)
					frameSize.width = size;
				else
					frameSize.height = size;
				view.setFrameSize(frameSize);
			}
			CGFloat offset = 0;
			CGFloat dividerThickness = this.dividerThickness();
			for (int i = 0; i < subviews.count(); i++)
			{
				NSView view = subviews.objectAtIndex(i);
				NSRect viewFrame = view.frame;
				NSPoint viewOrigin = viewFrame.origin;
				if (isVertical)
				{
					viewOrigin.x = offset;
					view.setFrameOrigin(viewOrigin);
					offset += (viewFrame.size.width + dividerThickness);
				}
				else
				{
					viewOrigin.y = offset;
					view.setFrameOrigin(viewOrigin);
					offset += (viewFrame.size.height + dividerThickness);
				}
			}
		}

		private void splitViewDidResizeSubviews(NSNotification notification)
		{
			if ((_delegate2 != null) && _delegate2.respondsToSelector(__selector(splitViewDidResizeSubviews:)))
				_delegate2.splitViewDidResizeSubviews(this);
		}

		private NSImageView handleImage;
		private bool handleOnRight;

		private CGFloat _minTopLeft;
		public CGFloat minTopLeft
		{
			get { return _minTopLeft; }
			set { _minTopLeft = value; }
		}

		private CGFloat _minBottomRight;
		public CGFloat minBottomRight
		{
			get { return _minBottomRight; }
			set { _minBottomRight = value; }
		}

		private CGFloat _maxTopLeft;
		public CGFloat maxTopLeft
		{
			get { return _maxTopLeft; }
			set { _maxTopLeft = value; }
		}

		private CGFloat _maxBottomRight;
		public CGFloat maxBottomRight
		{
			get { return _maxBottomRight; }
			set { _maxBottomRight = value; }
		}

		private int _priorityViewIndex;
		public int priorityViewIndex
		{
			get { return _priorityViewIndex; }
			set { _priorityViewIndex = value; }
		}

		public bool secondaryViewIsHidden
		{
			get
			{
				if (_priorityViewIndex == 0)
				{
					return this.positionOfDividerAtIndex(0) >= this.totalSize();
				}
				else
					if (_priorityViewIndex == 1)
					{
						return this.positionOfDividerAtIndex(0) <= 0;
					}
				return false;
			}
		}

		private __weak ITPSplitViewDelegate _delegate2;
		public ITPSplitViewDelegate delegate2
		{
			get { return _delegate2; }
			set { _delegate2 = value; }
		}

		public CGFloat positionOfDividerAtIndex(NSInteger index)
		{
			if (this.isVertical())
				return this.subviews().objectAtIndex(index).frame().size.width;
			else
				return this.subviews().objectAtIndex(index).frame().size.height;
		}
	}
}
