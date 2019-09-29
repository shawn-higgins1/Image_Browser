# frozen_string_literal: true

module ApplicationHelper
  def get_title(page_title = '')
    base_title = "Image Browser"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def current_page(controller, action)
    'active' if controller_name == controller && action_name == action
  end
end
