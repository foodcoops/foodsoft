class PollVote < ActiveRecord::Base
  belongs_to :poll
  belongs_to :ordergroup, optional: true
  belongs_to :user
  has_many :poll_choices, dependent: :destroy
end
