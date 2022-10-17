class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :country
      t.string :phone_number
      t.date :date_of_birth
      t.boolean :sms_consent
      t.boolean :is_klavio_successful

      t.timestamps
    end
  end
end
