# frozen_string_literal: true

class CreatePhotos < ActiveRecord::Migration[6.0]
  def change
    create_table :photos do |t|
      t.string :title
      t.boolean :visibility
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
