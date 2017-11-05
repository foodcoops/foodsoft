class PollChoice < ActiveRecord::Base
  belongs_to :poll_vote, touch: true
end
