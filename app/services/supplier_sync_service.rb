# app/services/supplier_sync_service.rb
class SupplierSyncService
  def initialize(supplier)
    @supplier = supplier
  end

  def sync
    updated, deleted, created = @supplier.sync_from_remote
    persist(created, deleted, updated)
  rescue StandardError => e
    Rails.logger.error("Error syncing supplier #{@supplier.id}: #{e.message}")
    false
  end

  private

  def persist(created, deleted, updated)
    has_errors = !created.map(&:save).all?
    has_errors ||= !deleted.map(&:mark_as_deleted).all?
    result = updated.map do |article, attributes|
      article.latest_article_version.article_unit_ratios.clear
      article.latest_article_version.assign_attributes(attributes)
      article.save
    end
    has_errors ||= !result.all?
    !has_errors
  end
end
