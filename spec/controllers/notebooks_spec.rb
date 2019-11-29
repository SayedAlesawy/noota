# frozen_string_literal: true
require 'rails_helper'
RSpec.describe NotebooksController, type: :request do
  context '#index' do
    let!(:url) { '/notebooks' }

    context 'When there are no notebooks' do
      let!(:expected_response) { [] }

      it 'should return an empty array' do
        get url
        
        expect(response.body).to eq expected_response.to_json
      end
    end
  end
end
