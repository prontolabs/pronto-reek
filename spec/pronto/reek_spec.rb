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
    end
  end
end
