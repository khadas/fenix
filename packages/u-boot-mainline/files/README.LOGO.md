# uboot LOGO / SPLASH

uboot LOGO, displayed after uboot activate display

## LOGO PATHS

    + MMC|SD /splash.bmp                    (1st partition)
    + MMC|SD /usr/share/fenix/logo/logo.bmp (2nd partition)

## INFO

    file splash.*
    splash.bmp       PC bitmap, Windows 3.x format, 32 bit per pixel (bgra - pixel_format)
    splash.bmp.gz    gzip compressed data, was "splash.bmp"

raw bmp and gzipped bmp must have same name splash.bmp or logo.bmp
and same .bmp extension (without .gz)


## PACK

    gzip -9c splash.raw.bmp > splash.bmp

## UNPACK

    file splash.bmp | grep gzip \
    gzip -dc splash.bmp > splash.raw.bmp

## CUSTOMIZE

very easy customize  boot LOGO, logo-file is simple BMP file (or gzipped BMP)


