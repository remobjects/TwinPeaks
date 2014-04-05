//
//  TPGradientShared.m
//  TwinPeaks
//
//  Created by marc hoffman on 12/16/09.
//  Copyright 2009 RemObjects Software. All rights reserved.
//

#import "TPGradientShared.h"


// CoreGraphics gradient helpers

void _linearColorBlendFunction(void *info, const CGFloat *in, CGFloat *out)
{
	_twoColorsType *twoColors = info;
	
	out[0] = (1.0 - *in) * twoColors->red1 + *in * twoColors->red2;
	out[1] = (1.0 - *in) * twoColors->green1 + *in * twoColors->green2;
	out[2] = (1.0 - *in) * twoColors->blue1 + *in * twoColors->blue2;
	out[3] = (1.0 - *in) * twoColors->alpha1 + *in * twoColors->alpha2;
}

void _linearColorReleaseInfoFunction(void *info)
{
	free(info);
}

