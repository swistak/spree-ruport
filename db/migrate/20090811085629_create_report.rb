class CreateReport < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.string :report_type    
      t.string :comment 
      t.string :report_title

      t.string :permalink
      
      t.timestamp :start_at
      t.timestamp :end_at
      t.timestamps
    end

    add_index :reports, [:report_type, :id]
    add_index :reports, :report_title
  end

  def self.down
    drop_table :reports
  end
end
