/*
 * Copyright (c) 2010 devnight.net. All rights reserved.  Use of this
 * source code is governed by a MIT license that can be found at
 * http://devnight.net/LICENSE/MIT
 *
 * Image processing example for iOS
 * http://github.com/ragingwind/image-processing.cc
 *
 * @version 0.1
 * @author ragingwind@gmail.com
 *
 */

#import "ColorConverter.h"


void rgb2yiq(PRGB rgb, PYIQ yiq) {
  yiq->y = (UInt8) (0.3 * rgb->r + 0.59 * rgb->g + 0.11 * rgb->b);
  yiq->i = (UInt8) (0.595716 * rgb->r + (-0.274453 * rgb->g) + (-0.321263 * rgb->b));
  yiq->q = (UInt8) (0.211456 * rgb->r + (-0.522591 * rgb->g) + (0.311135* rgb->b));
}

void rgb2hsi(PRGB rgb, PHSI hsi) {
  CGFloat min = MIN(MIN(rgb->r, rgb->g), rgb->b);
  hsi->i = (rgb->r + rgb->g + rgb->b) / 3.0f;
  if ((rgb->r == rgb->g) && (rgb->g == rgb->b)) {
	hsi->s = 0.0f;
	hsi->h = 0.0f;
  }
  else {
	hsi->s = 1.0f - (3.0f / (rgb->r + rgb->g + rgb->b)) * min;
	CGFloat angle = (rgb->r - 0.5f * rgb->g - 0.5f * rgb->b) / (CGFloat) sqrt((rgb->r - rgb->g) * (rgb->r - rgb->g) + (rgb->r - rgb->b) * (rgb->g - rgb->b));
	hsi->h = (CGFloat) acos(angle);
	hsi->h *= 57.29577951f;
	if (rgb->b > rgb->g)
	  hsi->h = 360.f - hsi->h;
  }
}

void hsi2rgb(PHSI hsi, PRGB rgb) {
  rgb->r = 0.f;
  rgb->g = 0.f;
  rgb->b = 0.f;  
  if (hsi->i != 0.0f) {
	if (hsi->s == 0.0f) {
	  rgb->r = rgb->g = rgb->b = hsi->i;
	}
	else {
	  if (hsi->h < 0.0f)
		hsi->h += 360.f;
	  
	  hsi->h = hsi->h / 360.f;
	  
	  if ((hsi->h > 120.f) && (hsi->h <= 240.f))
		hsi->h -= 120.f;
	  else if (hsi->h > 240.f)
		hsi->h -= 240.f;
  
	  CGFloat scale = 3.0f * hsi->i;
	  CGFloat angle1 = hsi->h * 0.017453293f;
	  CGFloat angle2 = (60.0f - hsi->h) * 0.017453293f;
	  	  
	  if (hsi->h <= 120.0f) {		
		rgb->r = (CGFloat) (1.0f + (hsi->s * cos(angle1) / cos(angle2))) / 3.0f;
		rgb->b = (1.0f - hsi->s) / 3.0f;	
		rgb->g = 1.0f - rgb->r - rgb->b;
	  }
	  else if ((hsi->h > 120.0f) && (hsi->h <= 240.0f)) {
		rgb->g = (CGFloat) (1.0f + (hsi->s * cos(angle1) / cos(angle2))) / 3.0f;
		rgb->r = (1.0f - hsi->s) / 3.0f;	
		rgb->b = 1.0f - rgb->r - rgb->g;
	  }
	  else {
		rgb->b = (CGFloat) (1.0f + (hsi->s * cos(angle1) / cos(angle2))) / 3.0f;
		rgb->g = (1.0f - hsi->s) / 3.0f;	
		rgb->r = 1.0f - rgb->g - rgb->b;
	  }
	  rgb->r *= scale;
	  rgb->g *= scale;
	  rgb->b *= scale;
	}	
  }
}

void rgb2hsl(PRGB rgb, PHSL hsl) {
  CGFloat r = (rgb->r / 255.f);
  CGFloat g = (rgb->g / 255.f);
  CGFloat b = (rgb->b / 255.f);
  
  CGFloat min = MIN(MIN(r, g), b);
  CGFloat max = MAX(MAX(r, g), b);
  CGFloat delta = max - min;
  
  hsl->l = (max + min) / 2;
  if (delta == 0) {
	hsl->s = 0.0f;
	hsl->h = 0.0f;
  }
  else {
	hsl->s = (hsl->l <= 0.5) ? (delta / (max + min)) : (delta / (2 - max - min));
	CGFloat hue = 0.f;
	if (r == max)
	  hue = ((g - b) / 6) / delta;
	else if (g == max) 
	  hue = (1.0 / 3) + ((b - r) / 6) / delta;
	else
	  hue = (2.0 / 3) + ((r - g) / 6) / delta;
	
	if (hue < 0)
	  hue += 1;
	if (hue > 1)
	  hue -= 1;
	
	hsl->h = (hue * 360);
  }
}

CGFloat hue2rgb(CGFloat v1, CGFloat v2, CGFloat h) {
  if ( h < 0 )
	h += 1;
  if ( h > 1 )
	h -= 1;
  if ( ( 6 * h ) < 1 )
	return ( v1 + ( v2 - v1 ) * 6 * h );
  if ( ( 2 * h ) < 1 )
	return v2;
  if ( ( 3 * h ) < 2 )
	return ( v1 + ( v2 - v1 ) * ( ( 2.0 / 3 ) - h ) * 6 );
  return v1;
}

void hsl2rgb(PHSL hsl, PRGB rgb) {
  if (hsl->s == 0)
	rgb->r = rgb->g = rgb->b = (hsl->l * 255.f);
  else {
	CGFloat hue = hsl->h / 360.f;
	CGFloat v2 = (hsl->l < 0.5) ? (hsl->l * (1 + hsl->s)) : ((hsl->l + hsl->s) - (hsl->l * hsl->s));
	CGFloat v1 = 2 * hsl->l - v2;
	
	rgb->r = (255.f * hue2rgb(v1, v2, hue + (1.0 / 3)));
	rgb->g = (255.f * hue2rgb(v1, v2, hue));
	rgb->b = (255.f * hue2rgb(v1, v2, hue - (1.0 / 3)));
  }
}

void rgb_desaturation(PRGB rgb, CGFloat s) {
  CGFloat avg = (rgb->r + rgb->g + rgb->b) / 3.0;
  rgb->r = CLAMP((rgb->r - avg) * s + avg, 0.f, 255.f);
  rgb->g = CLAMP((rgb->g - avg) * s + avg, 0.f, 255.f);
  rgb->b = CLAMP((rgb->b - avg) * s + avg, 0.f, 255.f);
}
