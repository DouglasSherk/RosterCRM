class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :maybe_fetch_calendar

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to permissions_denied_path, alert: exception.message
  end

  private
    def maybe_fetch_calendar
      return if current_user.nil? ||
        (!current_user.last_calendar_fetch.nil? &&
         # XXX/drs: Hilariously bad order of operations issue here.
         # You can't put the `DateTime.now` first or it won't trip whatever
         # operator is making this happen. So instead, reverse the order and
         # then invert the result.
         -1 * (current_user.last_calendar_fetch - DateTime.now) < 5*60)
      fetch_calendar
      current_user.last_calendar_fetch = DateTime.now
      current_user.save
    end

    def fetch_calendar
      client = Google::APIClient.new
      client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
      client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
      client.authorization.access_token = current_user.token
      client.authorization.refresh_token = current_user.refresh_token
      client.authorization.expires_at = current_user.expires_at if !current_user.expires_at.nil?
      service = client.discovered_api('calendar', 'v3')

      if client.authorization.refresh_token && client.authorization.expired?
        client.authorization.fetch_access_token!
        current_user.token = client.authorization.access_token
        current_user.save
      end

      response = client.execute({
        api_method: service.calendar_list.list,
        parameters: {}
      })

      calendar = response.data['items'].find { |item| item['summary'] == 'RosterCRM' }
      return if calendar.nil?
      id = calendar['id']

      response = client.execute({
        api_method: service.events.list,
        parameters: {
          calendarId: id
        }
      })
      parse_calendar(response.data['items'])
    end

    def parse_calendar(events)
      events.each do |event|
        # First, check if this customer exists. If not, create one.
        customer = Customer.find_by(user: current_user, name: event.summary)
        if customer.nil?
          customer = Customer.new(user: current_user, name: event.summary)
          customer.save
        end

        # Create or update an interaction based on this event.
        interaction = Interaction.find_by(customer: Customer.where(user: current_user), google_calendar_id: event['id'])
        if interaction.nil?
          interaction = Interaction.new({
            customer: customer,
            mode: :meeting,
            description: event['description'],
            google_calendar_id: event['id']
          })
        end
        interaction.time = event['start']['dateTime'].to_datetime
        interaction.save
      end

      # Find all orphaned interactions and delete them.
      interactions = Interaction.where(customer: Customer.where(user: current_user)).where.not(google_calendar_id: nil)
      interactions.each do |inter|
        interaction_event = events.find { |event| event['id'] == inter.google_calendar_id }
        inter.destroy if interaction_event.nil?
      end
    end
end
