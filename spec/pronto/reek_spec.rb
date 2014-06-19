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

      context 'patches with additions' do
        let(:patches) { [
          double("patch with additions", additions: 4, new_file_full_path: 'ruby_code.rb'),
          double("patch without additions", additions: 0) ] }

        let(:examiner) { double("examiner", smells: []) }

        before do
          ::Reek::Examiner.stub(:new).and_return examiner
        end

        it "calls reek with the files that have additions" do
          subject
          ::Reek::Examiner.should have_received(:new).with ['ruby_code.rb']
        end
      end

      context 'patches with additions to non-ruby files' do
        let(:patches) { [
          double("patch for ruby file", additions: 4, new_file_full_path: 'ruby_code.rb'),
          double("patch for non-ruby file", additions: 4, new_file_full_path: 'other.stuff') ] }

        let(:examiner) { double("examiner", smells: []) }

        before do
          ::Reek::Examiner.stub(:new).and_return examiner
        end

        it "calls reek with only the ruby files" do
          subject
          ::Reek::Examiner.should have_received(:new).with ['ruby_code.rb']
        end
      end
    end
  end
end
