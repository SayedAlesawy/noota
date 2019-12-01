# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe NotesController, type: :request do
  context '#index' do
    let!(:notebook_id) { 1 }
    let!(:url) { "/notebooks/#{notebook_id}/notes" }

    context 'When the notebook doesn\'t exist' do
      let!(:expected_response) { { message: 'record not found' } }

      it 'should return 404 not found' do
        get url
        
        expect(response.status).to eq 404
        expect(response.body).to eq expected_response.to_json
      end
    end

    context 'When the notebook does exist' do
      let!(:nb1) { Notebook.create(title: "Notebook1", description: "Notebooks1 does work1") }
      let!(:nb2) { Notebook.create(title: "Notebook2", description: "Notebooks2 does work2") }
       
      context 'When there are no notes' do 
        let!(:expected_response) { [] }
  
        it 'should return an empty array' do
          get url
          
          expect(response.status).to eq 200
          expect(response.body).to eq expected_response.to_json
        end
      end

      context 'When there are some notes' do
        before do
          nb1.notes.create(title: "Note1", body: "Note1 does work1", country: "Egypt")
          nb2.notes.create(title: "Note2", body: "Note2 does work2", country: "U.S.")
          nb1.notes.create(title: "Note3", body: "Note3 does work3", country: "Canada")
          nb2.notes.create(title: "Note4", body: "Note4 does work4", country: "Gremany")
        end
  
        let!(:expected_response) do
          JSON.parse(File.read("#{Rails.root}/spec/fixtures/controllers/notes/database_has_some_values.json"))
        end
  
        it 'should return an array of all records in the DB' do
          get url
          
          expect(response.status).to eq 200
          expect(response.body).to eq expected_response.to_json
        end
      end
    end
  end

  context '#show' do
    let!(:notebook_id) { 1 }
    let!(:id) { 1 }
    let!(:url) { "/notebooks/#{notebook_id}/notes/#{id}" }

    context 'When the notebook doesn\'t exist' do
      let!(:expected_response) { { message: 'record not found' } }

      it 'should return 404 not found' do
        get url
        
        expect(response.status).to eq 404
        expect(response.body).to eq expected_response.to_json
      end
    end

    context 'When the notebook does exist' do
      let!(:nb1) { Notebook.create(title: "Notebook1", description: "Notebooks1 does work1") }
      let!(:nb2) { Notebook.create(title: "Notebook2", description: "Notebooks2 does work2") }

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
          nb1.notes.create(title: "Note1", body: "Note1 does work1", country: "Egypt")
          nb2.notes.create(title: "Note2", body: "Note2 does work2", country: "U.S.")
          nb1.notes.create(title: "Note3", body: "Note3 does work3", country: "Canada")
          nb2.notes.create(title: "Note4", body: "Note4 does work4", country: "Gremany")
        end

        context 'Requested record does\'t exist' do
          let!(:id) { 2 }
          let!(:expected_response) { { message: 'record not found' } }

          it 'should return 404 not found' do
            get url
            
            expect(response.status).to eq 404
            expect(response.body).to eq expected_response.to_json
          end
        end

        context 'Requested record exists' do
          let!(:expected_response) { { id: 1, title: 'Note1', body: 'Note1 does work1', country: 'Egypt' } }

          it 'should return 200' do
            get url
            
            expect(response.status).to eq 200
            expect(response.body).to eq expected_response.to_json
          end
        end
      end
    end
  end

  context '#create' do
    let!(:notebook_id) { 1 }
    let!(:url) { "/notebooks/#{notebook_id}/notes/new" }
    
    let!(:title) { 'Note1' }
    let!(:body) { 'Notebook1 does all the work' }
    let!(:user_ip) { '24.48.0.1' }
    let!(:params) do
      {
        data: {
          title: title,
          body: body,
          user_ip: user_ip
        }
      }
    end

    before do
      stub_request(:get, "http://ip-api.com/json/#{user_ip}").
      with(
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: "{\"country\": \"dummy_country\"}", headers: {})
    end

    context 'When the notebook doesn\'t exist' do
      let!(:expected_response) { { message: 'record not found' } }

      it 'should return 404 not found' do
        post url, params: params
        
        expect(response.status).to eq 404
        expect(response.body).to eq expected_response.to_json
      end
    end

    context 'When the notebook does exist' do
      let!(:nb1) { Notebook.create(title: "Notebook1", description: "Notebooks1 does work1") }
      let!(:nb2) { Notebook.create(title: "Notebook2", description: "Notebooks2 does work2") }

      context 'When params are correct' do
        let!(:expected_response) { { message: 'success' } }

        it 'should return 201' do
          post url, params: params
          
          expect(response.status).to eq 201
          expect(response.body).to eq expected_response.to_json
        end

        it 'should enqueue a job in the noota::notes-creator queue' do
          expect { post url, params: params }.to change(
            Sidekiq::Queues['noota::notes-creator'], :size
          ).by(1)
        end
  
        it 'Should enqueue the job with the correct args' do
          post url, params: params
  
          expected_job_args = {
            title: 'Note1', 
            body: 'Notebook1 does all the work', 
            notebook_id: '1', 
            country: 'dummy_country'
          }
          
          expect(
            JSON.parse(Sidekiq::Queues['noota::notes-creator'].first.with_indifferent_access['args'].first
            ).symbolize_keys
          ).to eq(expected_job_args)
        end
      end

      context 'When some params are missing' do
        context 'When title is missing' do
          before do
            params[:data].delete(:title)
          end

          let!(:expected_response) { { message: 'param is missing or the value is empty: title' } }

          it 'should return 400' do
            post url, params: params
            
            expect(response.status).to eq 400
            expect(response.body).to eq expected_response.to_json
          end
        end

        context 'When body is missing' do
          before do
            params[:data].delete(:body)
          end

          let!(:expected_response) { { message: 'param is missing or the value is empty: body' } }

          it 'should return 400' do
            post url, params: params
            
            expect(response.status).to eq 400
            expect(response.body).to eq expected_response.to_json
          end
        end
      end
    end 
  end

  context '#destroy' do
    let!(:notebook_id) { 1 }
    let!(:id) { 1 }
    let!(:url) { "/notebooks/#{notebook_id}/notes/#{id}" }

    context 'When the notebook doesn\'t exist' do
      let!(:expected_response) { { message: 'record not found' } }

      it 'should return 404 not found' do
        delete url
        
        expect(response.status).to eq 404
        expect(response.body).to eq expected_response.to_json
      end
    end

    context 'When the notebook does exist' do
      before do
        nb1 = Notebook.create(title: "Notebook1", description: "Notebooks1 does work1")
        nb2 = Notebook.create(title: "Notebook2", description: "Notebooks2 does work2")

        nb1.notes.create(title: "Note1", body: "Note1 does work1", country: "Egypt")
        nb2.notes.create(title: "Note2", body: "Note2 does work2", country: "U.S.")
        nb1.notes.create(title: "Note3", body: "Note3 does work3", country: "Canada")
        nb2.notes.create(title: "Note4", body: "Note4 does work4", country: "Gremany")
      end

      context 'Requested record does\'t exist' do
        let!(:id) { 5 }
        let!(:expected_response) { { message: 'record not found' } }

        it 'should return 404 not found' do
          delete url
          
          expect(response.status).to eq 404
          expect(response.body).to eq expected_response.to_json
        end

        it 'should\'t change the size of the note relation' do
          expect{ delete url }.to_not change{ Note.count }
        end
      end

      context 'Requested record exists' do
        let!(:expected_response) { { message: 'success' } }
  
        it 'should return 202' do
          delete url
          
          expect(response.status).to eq 202
          expect(response.body).to eq expected_response.to_json
        end
  
        it 'should decrease the size of the note relation by 1' do
          expect{ delete url }.to change{ Note.count }.from(Note.count).to(Note.count - 1)
        end
  
        it 'should delete the requested record' do
          delete url
  
          expect { Note.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  context '#bulk_destroy' do
    let!(:notebook_id) { 1 }
    let!(:url) { "/notebooks/#{notebook_id}/notes/" }

    context 'When the notebook doesn\'t exist' do
      let!(:expected_response) { { message: 'record not found' } }

      it 'should return 404 not found' do
        delete url
        
        expect(response.status).to eq 404
        expect(response.body).to eq expected_response.to_json
      end
    end

    context 'When the notebook does exist' do
      before do
        nb1 = Notebook.create(title: "Notebook1", description: "Notebooks1 does work1")
        nb2 = Notebook.create(title: "Notebook2", description: "Notebooks2 does work2")
      end

      let!(:expected_response) { { message: 'success' } }

      it 'should return 202' do
        delete url
        
        expect(response.status).to eq 202
        expect(response.body).to eq expected_response.to_json
      end

      it 'should enqueue a job in the noota::notes-bulk-destroyer queue' do
        expect { delete url }.to change(
          Sidekiq::Queues['noota::notes-bulk-destroyer'], :size
        ).by(1)
      end

      it 'Should enqueue the job with the correct args' do
        delete url

        expected_job_args = {
          notebook_id: '1'
        }
        
        expect(
          JSON.parse(Sidekiq::Queues['noota::notes-bulk-destroyer'].first.with_indifferent_access['args'].first
          ).symbolize_keys
        ).to eq(expected_job_args)
      end
    end
  end
end
