# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe NotesBulkDestroyer do
  let!(:nb1) { Notebook.create(title: "Notebook1", description: "Notebooks1 does work1") }
  let!(:nb2) { Notebook.create(title: "Notebook2", description: "Notebooks1 does work2") }

  before do
    nb1.notes.create(title: "Note1", body: "Note1 does work1", country: "Egypt")
    nb2.notes.create(title: "Note2", body: "Note2 does work2", country: "U.S.")
    nb1.notes.create(title: "Note3", body: "Note3 does work3", country: "Canada")
    nb2.notes.create(title: "Note4", body: "Note4 does work4", country: "Gremany")
  end

  context 'Executes the job correctly' do
    let!(:args) do
      {
        notebook_id: 1
      }
    end

    it 'should decrease the size of the notes relation by 2' do
      expect { NotesBulkDestroyer.new.perform(args.to_json) }.to change{
        Note.count
      }.from(Note.count).to(Note.count - 2)
    end

    it 'should remove the the requested notes' do
      ids = nb1.notes.pluck(:id)

      NotesBulkDestroyer.new.perform(args.to_json)
      
      expect { Note.find(ids.first) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Note.find(ids.second) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
