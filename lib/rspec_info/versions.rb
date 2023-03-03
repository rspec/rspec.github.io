module RSpecInfo
  module Versions
    FEATURES_DIR = File.expand_path("../../../source/features", __FILE__)

    module_function

    def max(versions)
      versions.max_by { |version| version.gsub('-','.').to_f }
    end

    def rails_feature_versions
      @rails_versions ||= library_versions('rspec-rails')
    end

    def rspec_feature_versions
      @rspec_versions ||= library_versions('rspec-core')
    end

    def feature_versions
      directories(FEATURES_DIR).reduce({}) do |hash, version_path|
        hash[File.basename(version_path)] = directories(version_path).map { |dir| File.basename(dir) }
        hash
      end
    end

    def library_versions(library)
      feature_versions.reduce([]) do |versions, (version, dirs)|
        versions << version if dirs.find { |lib_dir| lib_dir == library }
        versions
      end.sort
    end

    def directories(folder)
      Dir[File.join(folder, '*')].select { |dir| Dir.exists?(dir) }
    end
  end
end
