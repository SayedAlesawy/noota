# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# Clean DB
Notebook.destroy_all
Note.destroy_all

# Add seed data

nb1 = Notebook.create!(title: "CMP Calendar", description: "A calendar to keep track of college related events")

nb1_n1 = nb1.notes.create!(title: "Project due date", body: "We need to deliver this project by 12-12-2019", notebook_id: nb1.id)
