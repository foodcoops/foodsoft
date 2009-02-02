# == Schema Information
# Schema version: 20090119155930
#
# Table name: article_prices
#
#  id            :integer         not null, primary key
#  article_id    :integer
#  price         :decimal(8, 2)   default(0.0), not null
#  tax           :decimal(8, 2)   default(0.0), not null
#  deposit       :decimal(8, 2)   default(0.0), not null
#  unit_quantity :integer
#  created_at    :datetime
#

class ArticlePrice < ActiveRecord::Base

  belongs_to :article
  has_many :order_articles

  # The financial gross, net plus tax and deposit.
  def gross_price
    ((price + deposit) * (tax / 100 + 1))
  end

  # The price for the foodcoop-member.
  def fc_price
    (gross_price  * (APP_CONFIG[:price_markup] / 100 + 1))
  end
end
