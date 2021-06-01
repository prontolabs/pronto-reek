# frozen_string_literal: true

require 'spec_helper'

module Pronto
  describe Reek do
    let(:reek) { Reek.new(patches) }
    let(:patches) { nil }

    describe '#run' do
      subject { reek.run }

      context 'patches are nil' do
        it { should == [] }
      end

      context 'no patches' do
        let(:patches) { [] }
        it { should == [] }
      end

      context 'patches with a two smells' do
        include_context 'test repo'

        let(:patches) { repo.diff('c04b312') }

        its(:count) { should == 2 }
        its(:'first.msg') do
          should \
            match(/Has the parameter name 'n' - \[UncommunicativeParameterName\]\(https:\/\/github.com\/troessner\/reek\/blob\/v\d+\.\d+\.\d+\/docs\/Uncommunicative-Parameter-Name.md\)/)
        end

        its(:'last.msg') do
          should \
            match(/Has the variable name '@n' - \[UncommunicativeVariableName\]\(https:\/\/github.com\/troessner\/reek\/blob\/v\d+\.\d+\.\d+\/docs\/Uncommunicative-Variable-Name.md\)/)
        end

        context 'when severity level configured on environment variable' do
          before { stub_const('ENV', 'PRONTO_REEK_SEVERITY_LEVEL' => 'fatal') }

          its(:'first.level') { should == :fatal }
        end

        context 'when severity level configured on file' do
          before { Pronto::ConfigFile.stub(:new).and_return('reek' => { 'severity_level' => 'error' }) }

          its(:'first.level') { should == :error }
        end
      end

      context 'patches with additions to non-ruby files' do
        let(:examiner) { double('examiner', smells: []) }
        let(:ruby_file) { Pathname.pwd.join('ruby_code.rb') }
        let(:other_file) { Pathname.pwd.join('other.stuff') }
        before { ::Reek::Examiner.stub(:new).and_return(examiner) }

        let(:patches) do
          [double('ruby', additions: 4, new_file_full_path: ruby_file),
           double('non-ruby', additions: 4, new_file_full_path: other_file)]
        end

        before do
          ::Pronto::Reek.any_instance.stub(:ruby_executable?).and_return(false)
        end

        it 'calls reek with only the ruby files' do
          subject
          ::Reek::Examiner.should have_received(:new).with(Pathname('ruby_code.rb'), hash_including(:configuration))
          ::Reek::Examiner.should_not have_received(:new).with other_file
        end
      end
    end
  end
end
