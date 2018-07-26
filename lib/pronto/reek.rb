require 'pronto'
require 'reek'

module Pronto
  class Reek < Runner
    def run
      files = ruby_patches.map(&:new_file_full_path)
      configuration = ::Reek::Configuration::AppConfiguration.from_path(nil)

      smells = files.flat_map do |file|
        ::Reek::Examiner.new(file, configuration: configuration).smells
      end
      messages_for(smells).compact
    end

    private

    def messages_for(errors)
      errors.map do |error|
        patch = patch_for_error(error)
        next if patch.nil?

        line = patch.added_lines.find do |added_line|
          error.lines.find { |error_line| error_line == added_line.new_lineno }
        end

        new_message(line, error) if line
      end
    end

    def new_message(line, error)
      path = line.patch.delta.new_file[:path]
      message = "#{error.message.capitalize} (#{error.smell_type})"

      Message.new(path, line, :info, message, nil, self.class)
    end

    def patch_for_error(error)
      ruby_patches.find do |patch|
        patch.new_file_full_path.to_s == error.source
      end
    end
  end
end
