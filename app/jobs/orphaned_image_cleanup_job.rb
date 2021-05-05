# frozen_string_literal: true

class OrphanedImageCleanupJob < ApplicationJob
  queue_as :default

  after_perform do |_job|
    self.class.set(wait: 1.day).perform_later
  end

  def perform(*_args)
    ActiveStorage::Blob.unattached.where("active_storage_blobs.created_at <= ?", 2.days.ago).find_each(&:purge_later)
  end
end
