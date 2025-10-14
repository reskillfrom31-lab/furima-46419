class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.reference :item, null: false, foreign_key: true
      t.timestamps
    end
  end
end
