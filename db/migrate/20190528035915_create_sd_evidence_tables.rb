class CreateSdEvidenceTables < ActiveRecord::Migration[5.2]
  def change
    create_table :sd_evidence_tables do |t|
      t.text :name
      t.references :sd_meta_datum, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
