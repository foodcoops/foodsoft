class PollVote < ActiveRecord::Base
  belongs_to :poll
  belongs_to :ordergroup
  belongs_to :user
  has_many :poll_choices, dependent: :destroy
end
