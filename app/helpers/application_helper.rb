# frozen_string_literal: true

module ApplicationHelper
    # Set the page title
    def get_title(page_title = '')
        base_title = I18n.t("title")
        if page_title.empty?
            base_title
        else
            page_title + " | " + base_title
        end
    end

    # Determine whether or not the current page is active or not.
    # This is used by the header to highlight the active link
    def current_page(controller, action)
        'active' if controller_name == controller && action_name == action
    end
end
