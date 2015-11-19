class AddLastCalendarFetchToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_calendar_fetch, :datetime
  end
end
