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


#ifndef CLAMP
#define CLAMP(v, min, max) ((v) < (min) ? min : (v) > (max) ? (max) : (v))
#endif

#ifndef WRAPCLAMP
#define WRAPCLAMP(v, max) ((UInt8) (v % (max))
#endif


typedef struct _RGB {
  CGFloat r;
  CGFloat g;
  CGFloat b;
  CGFloat reserved;
} RGB, *PRGB;

// YIQ is the color space used by the NTSC color TV system
// refer to http://en.wikipedia.org/wiki/YIQ
typedef struct _YIQ {
  CGFloat y;
  CGFloat i;
  CGFloat q;
} YIQ, *PYIQ;

typedef struct _HSI {
  CGFloat h;
  CGFloat s;
  CGFloat i;
} HSI, *PHSI;

typedef struct _HSL {
  CGFloat h;
  CGFloat s;
  CGFloat l;
} HSL, *PHSL;


void rgb2yiq(PRGB rgb, PYIQ yiq);
void rgb2hsi(PRGB rgb, PHSI hsi);
void hsi2rgb(PHSI hsi, PRGB rgb);
void rgb2hsl(PRGB rgb, PHSL hsl);
void hsl2rgb(PHSL hsl, PRGB rgb);
void rgb_desaturation(PRGB rgb, CGFloat s);

