# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrphanedImageCleanupJob, type: :job do
  describe "#perform" do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    after do
      ActiveJob::Base.queue_adapter = :inline
    end

    it "re-enques the job after completition" do
      freeze_time do
        expect do
          described_class.perform_now
        end.to have_enqueued_job.at(Time.current + 1.day)
      end
    end

    it "cleans up orphaned images" do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true

      ActiveStorage::Blob.create(filename: "test", byte_size: 0,
                                 created_at: Time.current - 3.days, checksum: 0, content_type: "text")

      create(:photo)

      expect do
        described_class.perform_now
      end.to change { ActiveStorage::Blob.count }.by(-1)
    end
  end
end
