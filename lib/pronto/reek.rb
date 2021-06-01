# frozen_string_literal: true

require 'pronto'
require 'reek'

module Pronto
  class Reek < Runner
    def run
      files = ruby_patches.map do |patch|
        patch.new_file_full_path.relative_path_from(Pathname.pwd)
      end

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
      message = "#{error.message.capitalize} - [#{error.smell_type}](#{error.explanatory_link})"

      Message.new(path, line, severity_level, message, nil, self.class)
    end

    def patch_for_error(error)
      ruby_patches.find do |patch|
        patch.new_file_full_path.relative_path_from(Pathname.pwd).to_s == error.source
      end
    end

    def severity_level
      @severity_level ||= begin
        ENV['PRONTO_REEK_SEVERITY_LEVEL'] || Pronto::ConfigFile.new.to_h.dig('reek', 'severity_level') || :info
      end.to_sym
    end
  end
end
