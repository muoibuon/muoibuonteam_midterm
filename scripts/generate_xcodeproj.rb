require "xcodeproj"

project_path = File.expand_path("../B2BInvoiceApp.xcodeproj", __dir__)
FileUtils.rm_rf(project_path) if Dir.exist?(project_path)

project = Xcodeproj::Project.new(project_path)

app_target = project.new_target(:application, "B2BInvoiceApp", :osx, "13.0")
app_target.build_configurations.each do |config|
  config.build_settings["SWIFT_VERSION"] = "5.0"
  config.build_settings["MACOSX_DEPLOYMENT_TARGET"] = "13.0"
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "YES"
  config.build_settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.muoi.B2BInvoiceApp"
  config.build_settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = ""
end

main_group = project.main_group
folders = %w[App Models Services Utilities Views]

folders.each do |folder_name|
  path = File.expand_path("../#{folder_name}", __dir__)
  next unless Dir.exist?(path)

  group = main_group.find_subpath(folder_name, true)
  group.set_source_tree("<group>")

  Dir.glob(File.join(path, "**/*.swift")).sort.each do |file_path|
    relative_path = file_path.sub("#{File.expand_path('..', __dir__)}/", "")
    file_ref = group.new_file(relative_path)
    app_target.add_file_references([file_ref])
  end
end

project.save
puts "Created #{project_path}"
