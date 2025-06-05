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

  # Persists changes to articles
  # @param created [Array<Article>] New articles to be created
  # @param deleted [Array<Article>] Articles to be marked as deleted
  # @param updated [Array<Article>, Array<Array<Article, Hash>>] Articles to be updated
  #   If updated is an array of articles, each article is expected to have its attributes already set
  #   If updated is an array of [article, attributes] pairs, the attributes will be assigned to the article
  # @param enable_unit_migration [Boolean] Whether to enable unit migration for the supplier
  # @return [Boolean] Whether all operations succeeded
  def persist(created, deleted, updated, enable_unit_migration: false)
    has_error = false
    Article.transaction do
      # re-enable unit migration if requested
      @supplier.update_attribute(:unit_migration_completed, nil) if enable_unit_migration

      # delete articles
      begin
        has_error = !deleted.map(&:mark_as_deleted).all? unless deleted.empty?
      rescue StandardError
        # raises an exception when used in current order
        has_error = true
      end

      # Update articles
      if updated.first.is_a?(Array)
        # Handle [article, attributes] pairs
        updated.each do |article, attributes|
          article.latest_article_version.article_unit_ratios.clear
          article.latest_article_version.assign_attributes(attributes)
          article.save or (has_error = true)
        end
      else
        # Handle articles with attributes already set
        updated.each do |article|
          article.save or (has_error = true)
        end
      end

      # Add new articles
      created.each { |a| a.save or has_error = true } unless created.empty?

      raise ActiveRecord::Rollback if has_error
    end

    !has_error
  end
end
