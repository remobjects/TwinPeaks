using AppKit;

namespace RemObjects.TwinPeaks.OSX
{
	public static class Private
	{
		public static void _windowDidChangeKeyNotification(this NSTableView @this, NSNotification notification)
		{
		}
	}

	void _linearColorBlendFunction(void* info, CGFloat @in, CGFloat @out)
	{
		_twoColorsType* twoColors = info;
		@out[0] = (((1D - *@in) * *twoColors.red1) + (*@in * *twoColors.red2));
		@out[1] = (((1D - *@in) * *twoColors.green1) + (*@in * *twoColors.green2));
		@out[2] = (((1D - *@in) * *twoColors.blue1) + (*@in * *twoColors.blue2));
		@out[3] = (((1D - *@in) * *twoColors.alpha1) + (*@in * *twoColors.alpha2));
	}

	void _linearColorReleaseInfoFunction(void* info)
	{
		free(info);
	}

	static CGFunctionCallbacks linearFunctionCallbacks;
}
