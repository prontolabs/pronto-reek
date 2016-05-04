require 'pronto'
require 'reek'

module Pronto
  class Reek < Runner
    def run
      files = ruby_patches.map(&:new_file_full_path)

      smells = files.flat_map do |file|
        ::Reek::Examiner.new(file).smells
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

        new_message(line, ErrorMessage.new(error).message) if line
      end
    end

    def new_message(line, message)
      path = line.patch.delta.new_file[:path]
      Message.new(path, line, :warning, message, nil, self.class)
    end

    def patch_for_error(error)
      ruby_patches.find do |patch|
        patch.new_file_full_path.to_s == error.source
      end
    end

    class ErrorMessage
      def initialize(error)
        @error = error
      end

      def message
        "#{description} ([#{smell_type}](#{link}))"
      end

      private

      attr_reader :error

      def reek_formatter
        @formatter ||= ::Reek::Report::WikiLinkWarningFormatter.new
      end

      def description
        error.message.capitalize
      end

      def smell_type
        error.smell_type
      end

      def link
        reek_formatter.format_hash(error).fetch('wiki_link')
      end
    end

    private_constant :ErrorMessage
  end
end
