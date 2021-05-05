# frozen_string_literal: true

namespace :active_storage do
  desc "Purges unattached Active Storage blobs. Run regularly."
  task purge_unattached: :environment do
    OrphanedImageCleanupJob.perform_later
  end
end
