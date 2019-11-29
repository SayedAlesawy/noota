# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NotebooksController, type: :request do
  context '#index' do
    let!(:url) { '/notebooks' }

    context 'When there are no notebooks' do
      let!(:expected_response) { [] }

      it 'should return an empty array' do
        get url
        
        expect(response.status).to eq 200
        expect(response.body).to eq expected_response.to_json
      end
    end

    context 'When there are some notebooks' do
      before do
        Notebook.create(title: "Notebook1", description: "Notebooks1 does work1")
        Notebook.create(title: "Notebook2", description: "Notebooks1 does work2")
        Notebook.create(title: "Notebook3", description: "Notebooks1 does work3")
        Notebook.create(title: "Notebook4", description: "Notebooks1 does work4")
      end

      let!(:expected_response) do
        JSON.parse(File.read("#{Rails.root}/spec/fixtures/controllers/notebooks/database_has_some_values.json"))
      end

      it 'should return an array of all records in the DB' do
        get url
        
        expect(response.status).to eq 200
        expect(response.body).to eq expected_response.to_json
      end
    end
  end

  context '#show' do
    let!(:id) { 1 }
    let!(:url) { "/notebooks/#{id}" }

    context 'When there are no records in the DB' do
      let!(:expected_response) { { message: 'record not found' } }

      it 'should return 404 not found' do
        get url
        
        expect(response.status).to eq 404
        expect(response.body).to eq expected_response.to_json
      end
    end

    context 'When there are records in the DB' do
      before do
        Notebook.create(title: "Notebook1", description: "Notebooks1 does work1")
        Notebook.create(title: "Notebook2", description: "Notebooks1 does work2")
      end

      context 'Requested record does\'t exist' do
        let!(:id) { 3 }
        let!(:expected_response) { { message: 'record not found' } }

        it 'should return 404 not found' do
          get url
          
          expect(response.status).to eq 404
          expect(response.body).to eq expected_response.to_json
        end
      end

      context 'Requested record exists' do
        let!(:expected_response) { { id: 1, title: 'Notebook1', description: 'Notebooks1 does work1' } }

        it 'should return 200' do
          get url
          
          expect(response.status).to eq 200
          expect(response.body).to eq expected_response.to_json
        end
      end
    end
  end

  context '#create' do
    let!(:url) { '/notebooks/new' }
    
    let!(:title) { 'Notebook1' }
    let!(:description) { 'Notebook1 does all the work' }
    let!(:params) do
      {
        data: {
          title: title,
          description: description
        }
      }
    end

    context 'When params are correct' do
      context 'When there are no records in the DB' do
        let!(:expected_response) { { id: 1, title: 'Notebook1', description: 'Notebook1 does all the work' } }

        it 'should return 201' do
          post url, params: params
          
          expect(response.status).to eq 201
          expect(response.body).to eq expected_response.to_json
        end

        it 'should increase the size of the notebook relation from 0 to 1' do
          expect{ post url, params: params }.to change{ Notebook.count }.from(0).to(1)
        end

        it 'should add a record that matches the sent params' do
          post url, params: params

          expect({ title: Notebook.first.title, description: Notebook.first.description }).to eq params[:data]
        end
      end

      context 'When there are some records in the DB' do
        before do
          Notebook.create(title: "Notebook1", description: "Notebooks1 does work1")
          Notebook.create(title: "Notebook2", description: "Notebooks1 does work2")
        end

        let!(:title) { 'Notebook3' }
        let!(:description) { 'Notebook3 does all the work' }

        let!(:expected_response) { { id: 3, title: 'Notebook3', description: 'Notebook3 does all the work' } }

        it 'should return 201' do
          post url, params: params
          
          expect(response.status).to eq 201
          expect(response.body).to eq expected_response.to_json
        end

        it 'should increase the size of the notebook relation by 1' do
          expect{ post url, params: params }.to change{ Notebook.count }.from(Notebook.count).to(Notebook.count + 1)
        end

        it 'should add a record that matches the sent params' do
          post url, params: params

          expect({ title: Notebook.last.title, description: Notebook.last.description }).to eq params[:data]
        end
      end
    end

    context 'When some required params are missing' do
      context 'When there are no records in the DB' do
        before do
          params[:data].delete(:title)
        end

        let!(:expected_response) { { message: 'Title can\'t be blank' } }

        it 'should return 422' do
          post url, params: params
          
          expect(response.status).to eq 422
          expect(response.body).to eq expected_response.to_json
        end

        it 'should\'t change the size of the notebook relation' do
          expect{ post url, params: params }.to_not change{ Notebook.count }
        end
      end

      context 'When there are some records in the DB' do
        before do
          Notebook.create(title: "Notebook1", description: "Notebooks1 does work1")
          Notebook.create(title: "Notebook2", description: "Notebooks1 does work2")

          params[:data].delete(:title)
        end

        let!(:expected_response) { { message: 'Title can\'t be blank' } }

        it 'should return 422' do
          post url, params: params
          
          expect(response.status).to eq 422
          expect(response.body).to eq expected_response.to_json
        end

        it 'should\'t change the size of the notebook relation' do
          expect{ post url, params: params }.to_not change{ Notebook.count }
        end
      end
    end
  end

  context '#destroy' do
    let!(:id) { 1 }
    let!(:url) { "/notebooks/#{id}" }

    context 'When there are no records in the DB' do
      let!(:expected_response) { { message: 'record not found' } }

      it 'should return 404 not found' do
        delete url
        
        expect(response.status).to eq 404
        expect(response.body).to eq expected_response.to_json
      end
    end

    context 'When there are records in the DB' do
      before do
        Notebook.create(title: "Notebook1", description: "Notebooks1 does work1")
        Notebook.create(title: "Notebook2", description: "Notebooks1 does work2")
      end

      context 'Requested record does\'t exist' do
        let!(:id) { 3 }
        let!(:expected_response) { { message: 'record not found' } }

        it 'should return 404 not found' do
          delete url
          
          expect(response.status).to eq 404
          expect(response.body).to eq expected_response.to_json
        end

        it 'should return 404 not found' do
          delete url
          
          expect(response.status).to eq 404
          expect(response.body).to eq expected_response.to_json
        end

        it 'should\'t change the size of the notebook relation' do
          expect{ delete url }.to_not change{ Notebook.count }
        end
      end

      context 'Requested record exists' do
        let!(:expected_response) { {} }

        it 'should return 202' do
          delete url
          
          expect(response.status).to eq 202
          expect(response.body).to eq expected_response.to_json
        end

        it 'should decrease the size of the notebook relation by 1' do
          expect{ delete url }.to change{ Notebook.count }.from(Notebook.count).to(Notebook.count - 1)
        end

        it 'should delete the requested record' do
          delete url

          expect { Notebook.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
