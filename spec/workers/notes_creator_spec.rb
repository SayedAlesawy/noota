# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe NotesCreator do
  before do
    Notebook.create(title: "Notebook1", description: "Notebooks1 does work1")
    Notebook.create(title: "Notebook2", description: "Notebooks1 does work2")
  end

  context 'Executes the job correctly' do
    let!(:args) do
      {
        title: 'Note1',
        body: 'Note1 should do work1',
        country: 'U.S.',
        notebook_id: 1
      }
    end

    it 'should increase the size of the notes relation by 1' do
      expect { NotesCreator.new.perform(args.to_json) }.to change{
        Note.count
      }.from(Note.count).to(Note.count + 1)
    end

    it 'should add the the requested note' do
      NotesCreator.new.perform(args.to_json)

      expect(
        {
          title: Note.last.title,
          body: Note.last.body,
          country: Note.last.country,
          notebook_id: Note.last.notebook_id 
        }
      ).to eq args
    end
  end
end
