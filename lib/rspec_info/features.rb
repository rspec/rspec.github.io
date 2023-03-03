module RSpecInfo
  module Features
    FEATURES_DIR = File.expand_path("../../../source/features", __FILE__)

    module_function

    def menu(library, version)
      @menu ||= {}
      @menu[library] ||= {}
      @menu[library][version] ||= generate_library_menu(library, version)
    end

    def sub_menu(library, version, topic)
      menu(library, version)[topic.gsub('-','_').humanize][:sub_menu]
    end

    def convert_path(path)
      return path if path =~ /\.html\.md$/
      path.gsub('_','-').gsub(/md$/, "html.md").gsub(/feature$/, "html.md")
    end

    def generate_library_menu(library, version)
      library_path = File.join(FEATURES_DIR, version, library)

      yaml = YAML.load(File.read(File.join(library_path, ".nav")))

      # Adds missing root files / directories
      Dir[File.join(library_path, "*")].each do |filename|
        entry = filename.split('/').last

        next if entry =~ /^index\.html\.(md|slim)$/
        next if yaml.any? { |hash_or_filename| Hash === hash_or_filename && hash_or_filename.has_key?(entry) }
        next if yaml.any? { |hash_or_filename| String === hash_or_filename && hash_or_filename.include?(entry.gsub("html.md", "feature")) }

        if entry =~ /\.html\.md$/
          yaml << entry
        else
          # Note not tested but logically this should hydate any missing directories...
          yaml << {entry => Dir[filename].map { |file| file.gsub(File.join(library_path, entry), '') }}
        end
      end

      yaml.reduce({}) do |menu, yaml_section|
        if Hash === yaml_section
          yaml_section.each do |heading, contents|
            yaml_path = File.join(FEATURES_DIR, version, library, heading)
            if Dir.exists?(yaml_path)

              # Add missing directory contents
              Dir[File.join(yaml_path, '*')].each do |filename|
                entry = filename.split('/').last

                next if entry.empty?
                next if entry =~ /^index\.html\.(md|slim)$/
                entry_as_feature = entry.gsub(/\.html\.md/, ".feature")
                next if contents.include?(entry_as_feature)

                contents << entry_as_feature
              end

              heading_key = heading.gsub('-','_').humanize

              menu[heading_key] = {path: heading}
              menu[heading_key][:sub_menu] = contents.reduce([]) do |sub_menu, filename|
                unless filename.nil? || filename.blank?
                  (filename_with_ext, optional_heading) = filename.split(' ', 2)
                  (filename_without_ext, _ext) = filename_with_ext.split('.', 2)
                  filename_in_library = File.join(library_path, heading, convert_path(filename_with_ext))

                  if File.exist?(filename_in_library)
                    # Replicate old .nav functionality
                    sub_heading =
                      if optional_heading
                        optional_heading.gsub(/\((.*)\)/, "\\1")
                      else
                        CGI::escapeHTML(File.read(filename_in_library).split("\n").first.gsub(/^#+/,''))
                      end

                    sub_menu << {heading: sub_heading, path: filename_without_ext}
                  end
                end

                sub_menu
              end
            end
          end
        else
          yaml_path = convert_path(File.join(FEATURES_DIR, version, library, yaml_section))

          if File.exist?(yaml_path)
            yaml_without_ext = yaml_section.split('.').first
            menu[yaml_without_ext.gsub('-','_').humanize] = {path: yaml_without_ext, sub_menu: []}
          end
        end

        menu
      end
    end
  end
end
