class FinancialLink < ApplicationRecord
  has_many :bank_transactions
  has_many :financial_transactions
  has_many :invoices

  scope :incomplete, -> { with_full_sum.where.not('full_sums.full_sum' => 0) }
  scope :with_full_sum, -> {
    select(:id, :note, :full_sum).joins(<<-SQL)
      LEFT JOIN (
        SELECT id, COALESCE(bt_sum, 0) - COALESCE(ft_sum, 0) + COALESCE(i_sum, 0) AS full_sum
        FROM financial_links fl
        LEFT JOIN (
          SELECT financial_link_id, SUM(amount) AS bt_sum
          FROM bank_transactions
          GROUP BY financial_link_id
        ) bt ON bt.financial_link_id = fl.id
        LEFT JOIN (
          SELECT financial_link_id, SUM(amount) AS ft_sum
          FROM financial_transactions
          GROUP BY financial_link_id
        ) ft ON ft.financial_link_id = fl.id
        LEFT JOIN (
          SELECT financial_link_id, SUM(amount) AS i_sum
          FROM invoices
          GROUP BY financial_link_id
        ) i ON i.financial_link_id = fl.id
      ) full_sums ON full_sums.id = financial_links.id
    SQL
  }
end
