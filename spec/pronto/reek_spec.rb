require 'spec_helper'
require 'ostruct'

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

      let(:examiner) { double('examiner', smells: []) }
      before { ::Reek::Core::Examiner.stub(:new).and_return(examiner) }

      context 'patches with additions' do
        let(:patches) do
          [double('with', additions: 4, new_file_full_path: 'ruby_code.rb'),
           double('without', additions: 0)]
        end

        it 'calls reek with the files that have additions' do
          subject
          ::Reek::Core::Examiner.should have_received(:new).with ['ruby_code.rb']
        end
      end

      context 'patches with additions to non-ruby files' do
        let(:patches) do
          [double('ruby', additions: 4, new_file_full_path: 'ruby_code.rb'),
           double('non-ruby', additions: 4, new_file_full_path: 'other.stuff')]
        end

        before { ::Pronto::Reek.any_instance.stub(:ruby_executable?).and_return(false) }

        it 'calls reek with only the ruby files' do
          subject
          ::Reek::Core::Examiner.should have_received(:new).with ['ruby_code.rb']
        end
      end
    end
  end
end
