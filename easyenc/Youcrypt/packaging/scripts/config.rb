module BuildSettings

    PROJECT             = 'Youcrypt'
    PRODUCT             = 'Youcrypt'
    TARGET              = 'Youcrypt'
    SCHEME              = 'Youcrypt'
    CONFIGURATION       = 'Release'
    SDK                 = 'macosx10.8'

    # Relative to build script location
    BUILD_DIR_RELATIVE  = '../build'
    INTERMEDIATES_PATH  = "#{BUILD_DIR_RELATIVE}/build/intermediates"
    PRODUCTS_PATH       = "#{BUILD_DIR_RELATIVE}/build/products"
end

module PackageSettings

    PACKAGER                = 'freeze'
    
    PACKAGE_DIR_RELATIVE    = '../packaging'
    APP_PKG                 = "#{PACKAGE_DIR_RELATIVE}/youcrypt-app/youcrypt-app.packproj"
    META_PKG                = "#{PACKAGE_DIR_RELATIVE}/youcrypt-mpkg/YouCrypt.packproj"

end


