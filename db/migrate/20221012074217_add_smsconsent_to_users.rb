class AddSmsconsentToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :sms_consent, :boolean
  end
end
