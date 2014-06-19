require 'pronto'
require 'reek'

module Pronto
  class Reek < Runner
    def run(patches, _)
      return [] unless patches

      patches_with_additions = patches.select { |patch| patch.additions > 0 }
                                      .select { |patch| ruby_file?(patch.new_file_full_path) }
      files = patches_with_additions.map { |patch| patch.new_file_full_path.to_s }

      if files.any?
        examiner = ::Reek::Examiner.new(files)
        messages_for(patches_with_additions, examiner.smells).compact
      else
        []
      end
    end

    def messages_for(patches, errors)
      errors.map do |error|
        patch = patch_for_error(patches, error)

        if patch
          line = patch.added_lines.find do |added_line|
            error.lines.find { |error_line| error_line == added_line.new_lineno }
          end

          new_message(line, error) if line
        end
      end
    end

    def new_message(line, error)
      Message.new(line.patch.delta.new_file[:path], line, :warning,
                  "#{error.message.capitalize} (#{error.subclass})")
    end

    def patch_for_error(patches, error)
      patches.find do |patch|
        patch.new_file_full_path.to_s == error.location['source']
      end
    end
  end
end
