class AddGoogleCalendarIdToInteractions < ActiveRecord::Migration
  def change
    add_column :interactions, :google_calendar_id, :string
  end
end
