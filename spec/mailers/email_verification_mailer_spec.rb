# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailVerificationMailer, type: :mailer do
    describe "email_verification" do
        let(:user) { create(:user) }
        let(:mail) { described_class.with(user: user).email_verification('http://localhost:3000') }

        it "creates email" do
            expect(mail.subject).to eq(I18n.t("email_verification.subject"))
            expect(mail.to).to eq([user.email])
            expect(mail.from).to eq(["from@example.com"])
        end

        it "contains the hostname" do
            expect(mail.body.encoded).to include('http://localhost:3000')
        end
    end
end
