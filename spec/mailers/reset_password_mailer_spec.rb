# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResetPasswordMailer, type: :mailer do
    describe "reset_password" do
        let(:user) { create(:user) }
        let(:mail) { described_class.with(user: user).reset_password }

        it "creates email" do
            expect(mail.subject).to eq(I18n.t("reset_password.subject"))
            expect(mail.to).to eq([user.email])
            expect(mail.from).to eq(["no-reply@image_browser.com"])
        end

        it "contains at hostname" do
            expect(mail.body.encoded).to include('test.host')
        end
    end
end
