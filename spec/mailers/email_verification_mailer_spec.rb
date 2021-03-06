# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailVerificationMailer, type: :mailer do
    describe "email_verification" do
        let(:user) { create(:user) }
        let(:mail) { described_class.with(user: user).email_verification }

        it "creates email" do
            expect(mail.subject).to eq(I18n.t("email_verification.subject"))
            expect(mail.to).to eq([user.email])
            expect(mail.from).to eq(["no-reply@image_browser.com"])
        end

        it "contains the hostname" do
            expect(mail.body.encoded).to include('test.host')
        end
    end
end
