require 'spec_helper'

module Pronto
  describe Reek do
    let(:reek) { Reek.new }

    describe '#run' do
      subject { reek.run(patches, nil) }

      context 'patches are nil' do
        let(:patches) { nil }
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
          should ==
            "Has the parameter name 'n' (UncommunicativeParameterName)"
        end

        its(:'last.msg') do
          should ==
            "Has the variable name '@n' (UncommunicativeVariableName)"
        end
      end

      context 'patches with additions to non-ruby files' do
        let(:examiner) { double('examiner', smells: []) }
        let(:ruby_file) { Pathname.new('ruby_code.rb') }
        let(:other_file) { Pathname.new('other.stuff') }
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
          ::Reek::Examiner.should have_received(:new).with ruby_file
          ::Reek::Examiner.should_not have_received(:new).with other_file
        end
      end
    end
  end
end
