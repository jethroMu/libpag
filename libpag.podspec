PAG_ROOT = __dir__

vendorNames = "pathkit skcms libwebp"
commonCFlags = ["-DGLES_SILENCE_DEPRECATION -DTGFX_USE_WEBP_DECODE -DPAG_DLL -fvisibility=hidden -Wall -Wextra -Weffc++ -pedantic -Werror=return-type"]
# PAG_USE_FREETYPE=ON pod install
if ENV["PAG_USE_FREETYPE"] == 'ON'
  vendorNames += " freetype"
  commonCFlags += ["-DTGFX_USE_FREETYPE"]
  $rasterSourceFiles = ['tgfx/src/raster/coregraphics/BitmapContextUtil.h',
                       'tgfx/src/raster/coregraphics/BitmapContextUtil.mm',
                       'tgfx/src/raster/freetype/**/*.{h,cpp,mm}']

else
  commonCFlags += ["-DTGFX_USE_CORE_GRAPHICS"]
  $rasterSourceFiles = ['tgfx/src/raster/coregraphics/**/*.{h,cpp,mm}']
end
# PAG_USE_LIBAVC=OFF pod install
if ENV["PAG_USE_LIBAVC"] != 'OFF'
  vendorNames += " libavc"
  commonCFlags += ["-DPAG_USE_LIBAVC"]
end

if  ENV["PLATFORM"] == "mac"
  system("depsync mac")
  system("node build_vendor #{vendorNames} -o #{PAG_ROOT}/mac/Pods/pag-vendor -p mac")
else
  system("depsync ios")
  system("node build_vendor #{vendorNames} -o #{PAG_ROOT}/ios/Pods/pag-vendor -p ios --fatLib")
end

Pod::Spec.new do |s|
  s.name     = 'libpag'
  s.version  = '4.0.0'
  s.ios.deployment_target   = '9.0'
  s.osx.deployment_target   = '10.13'
  s.summary  = 'The pag library on iOS and macOS'
  s.homepage = 'https://pag.io'
  s.author   = { 'dom' => 'dom@idom.me' }
  s.requires_arc = false
  s.source   = {
    :git => 'https://github.com/tencent/libpag.git'
  }

  $source_files =   'include/pag/defines.h',
                    'include/pag/types.h',
                    'include/pag/gpu.h',
                    'include/pag/file.h',
                    'include/pag/pag.h',
                    'src/base/**/*.{h,cpp}',
                    'src/codec/**/*.{h,cpp}',
                    'src/video/**/*.{h,cpp}',
                    'src/rendering/**/*.{h,cpp}',
                    'src/platform/*.{h,cpp}',
                    'tgfx/src/base/**/*.{h,cpp}',
                    'tgfx/src/core/**/*.{h,cpp}',
                    'tgfx/src/gpu/*.{h,cpp}',
                    'tgfx/src/image/*.{h,cpp}',
                    'tgfx/src/raster/*.{h,cpp}',
                    'tgfx/src/gpu/opengl/*.{h,cpp,mm}',
                    'tgfx/src/image/webp/**/*.{h,cpp,mm}'

  s.source_files = $source_files + $rasterSourceFiles;

  s.compiler_flags = '-Wno-documentation'

  s.osx.public_header_files = 'src/platform/mac/*.h',
                              'src/platform/cocoa/*.h'
  s.osx.source_files =  'src/platform/mac/**/*.{h,cpp,mm,m}',
                        'src/platform/cocoa/**/*.{h,cpp,mm,m}',
                        'tgfx/src/gpu/opengl/cgl/*.{h,cpp,mm}',
                        'tgfx/src/platform/mac/**/*.{h,cpp,mm,m}',
                        'tgfx/src/platform/apple/**/*.{h,cpp,mm,m}'

  s.osx.frameworks   = ['ApplicationServices', 'AGL', 'OpenGL', 'QuartzCore', 'Cocoa', 'Foundation', 'VideoToolbox', 'CoreMedia']
  s.osx.libraries = ["iconv", "c++"]

  s.ios.public_header_files = 'src/platform/ios/*.h',
                              'src/platform/cocoa/*.h'
                              
  s.ios.source_files =  'src/platform/ios/*.{h,cpp,mm,m}',
                          'src/platform/ios/private/*.{h,cpp,mm,m}',
                          'src/platform/cocoa/**/*.{h,cpp,mm,m}',
                          'tgfx/src/gpu/opengl/eagl/*.{h,cpp,mm}',
                          'tgfx/src/platform/ios/**/*.{h,cpp,mm,m}',
                          'tgfx/src/platform/apple/**/*.{h,cpp,mm,m}'

  s.ios.frameworks   = ['UIKit', 'CoreFoundation', 'QuartzCore', 'CoreGraphics', 'CoreText', 'OpenGLES', 'VideoToolbox', 'CoreMedia']
  s.ios.libraries = ["iconv"]

  s.xcconfig = {'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17','CLANG_CXX_LIBRARY' => 'libc++',"HEADER_SEARCH_PATHS" => "#{PAG_ROOT}/src #{PAG_ROOT}/include #{PAG_ROOT}/tgfx/src #{PAG_ROOT}/tgfx/include #{PAG_ROOT}/third_party/pathkit #{PAG_ROOT}/third_party/skcms #{PAG_ROOT}/third_party/freetype/include #{PAG_ROOT}/third_party/libwebp/src #{PAG_ROOT}/third_party/libavc/common #{PAG_ROOT}/third_party/libavc/decoder"}
  s.ios.xcconfig = {"OTHER_CFLAGS" => commonCFlags.join(" "),"EXPORTED_SYMBOLS_FILE" => "${PODS_ROOT}/../libpag.lds","OTHER_LDFLAGS" => "-w","VALIDATE_WORKSPACE_SKIPPED_SDK_FRAMEWORKS" => "OpenGLES"}
  s.osx.xcconfig = {"OTHER_CFLAGS" => commonCFlags.join(" ")}
  s.ios.vendored_libraries = 'ios/Pods/pag-vendor/libpag-vendor.a'
  s.osx.vendored_libraries = 'mac/Pods/pag-vendor/x64/libpag-vendor.a'

end
