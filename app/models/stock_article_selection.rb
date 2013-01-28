# encoding: utf-8
class StockArticleSelection < ActiveRecord::Base
  
  # Associations
  has_and_belongs_to_many :stock_articles
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_user_id'
  belongs_to :finished_by, :class_name => 'User', :foreign_key => 'finished_by_user_id'
  
  # Validations
  validate :include_stock_articles
  
  def all_articles
    all_articles = stock_article_ids
  end
  
  def deletable_count
    stock_articles.select { |a| a.quantity_available<=0 }.length
  end
  
  def nondeletable_count
    stock_articles.select { |a| a.quantity_available>0 }.length
  end
  
  def deleted_count
    stock_articles.only_deleted.count
  end
  
  protected
  
  def include_stock_articles
    errors.add(:stock_articles, "Es muss mindestens ein Lagerartikel ausgewählt sein.") if stock_articles.empty?
  end
  
  private
  
end
