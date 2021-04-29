# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
    default from: 'no-reply@image_browser.com'
    layout 'mailer'
end
