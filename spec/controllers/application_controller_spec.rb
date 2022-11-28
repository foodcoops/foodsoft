# frozen_string_literal: true

require 'spec_helper'

describe ApplicationController, type: :controller do
  describe 'current' do
    it 'returns current ApplicationController' do
      described_class.new.send(:store_controller)
      expect(described_class.current).to be_instance_of described_class
    end
  end
end
