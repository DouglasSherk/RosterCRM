module CustomersHelper
  def gray_out_inaccessible(customer)
    customer.active?(current_user.city_country) ? '' : 'class=inaccessible'
  end

  def status_color(status)
    colors = {
      :communication => 'active',
      :meeting => 'info',
      :close => 'success',
      :termination => 'danger'
    }
    colors[status]
  end

  def quality_color(quality)
    return "transparent" if quality.nil?
    red = 200 - 20*quality
    green = 20*quality
    "rgba(#{red}, #{green}, 0, 0.3)"
  end

  def interaction_color(interaction, past=false)
    return "" if interaction.nil? or interaction - DateTime.now < 0
    return 'info' if interaction - DateTime.now <= 2.days
    nil
  end
end
