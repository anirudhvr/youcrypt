#!/usr/bin/env ruby

require 'yc-pkgconfig'
require 'open3'
require 'fileutils'

class Builder
    include BuildSettings

    def initialize(opts = {}) 
        @project = opts[:project] || PROJECT
        @product = opts[:product] || PRODUCT
        @target  = opts[:target] || TARGET
        @scheme  = opts[:scheme] || SCHEME
        @configuration = opts[:configuration] || CONFIGURATION
        @sdk           = opts[:sdk] || SDK

        @script_dir = File.expand_path(File.dirname($0))
        @build_dir  = "#{@script_dir}/#{BUILD_DIR_RELATIVE}"
        @intermediates_path = "#{@script_dir}/#{INTERMEDIATES_PATH}"
        @products_path = "#{@script_dir}/#{PRODUCTS_PATH}"
    end

    def build
        %Q{@build_dir @intermediates_path @products_path}.each do |dir|
            if !File.exists?(dir)
                Directory.mkdir(dir)
            elsif !File.directory?(dir)
                raise "#{dir} exists but is not a dir"
            end
        end

        # clear the products path of the product
        FileUtils.rm_rf("#{@products_path}/#{@product}.app")


        stdin, stdout, stderr = Open3.popen3("xcodebuild -target #{@target} " +
                                             "-scheme #{@scheme} " +
                                             "-configuration #{@configuration} " +
                                             "-sdk #{@sdk} " +
                                             "OBJROOT=#{@intermediates_path} " +
        "SYMROOT=#{@products_path}")

        errors =  stderr.readlines
        if File.directory?("#{@products_path}/#{@product}.app")
            puts "xcodebuild succeeded"
        else
            puts "xcodebuild errors: #{errors}"
        end
    end

end

class Packager
    include PackageSettings
    require 'nokogiri'

    def initialize(opts = {})
        @app_path               = opts[:app_path] || raise "Need app path to proceed"
        @packager               = opts[:packager] || PACKAGER
        @package_dir_relative   = opts[:package_dir_relative] || PACKAGE_DIR_RELATIVE
        @app_pkg                = opts[:app_pkg] || APP_PKG
        @meta_pkg               = opts[:meta_pkg] || META_PKG
    end

    def package
        doc = XmlSimple.xml_in(@app_pkg)
        raise "Cannot parse XML in #{@app_pkg}" unless hash
        h["dict"][0]["dict"][0]["dict"][0]["dict"][1]["dict"][0]["array"][0]["dict"][0]["array"][0]["dict"][0]["array"][0]["dict"][0]["string"] = @app_path
        XmlSimple.xml_out(@app_pkg)






end




        





end
