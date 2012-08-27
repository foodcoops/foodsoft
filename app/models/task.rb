class Task < ActiveRecord::Base
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments
  belongs_to :workgroup

  scope :non_group, :conditions => { :workgroup_id => nil, :done => false }
  scope :done, :conditions => {:done => true}, :order => "due_date DESC"
  
  # form will send user in string. responsibilities will added later
  attr_protected :users

  validates :name, :presence => true, :length => { :minimum => 3 }
  validates :required_users, :presence => true
  validates_numericality_of :duration, :required_users, :only_integer => true, :greater_than => 0
  validates_length_of :description, maximum: 250

  after_save :update_ordergroup_stats
  
  def is_assigned?(user)
    self.assignments.detect {|ass| ass.user_id == user.id }
  end
  
  def is_accepted?(user)
    self.assignments.detect {|ass| ass.user_id == user.id && ass.accepted }
  end
  
  def enough_users_assigned?
    assignments.find_all_by_accepted(true).size >= required_users ? true : false
  end

  # Get users from comma seperated ids
  # and makes the users responsible for the task
  def user_list=(ids)
    list = ids.split(",")
    new_users = list - users.collect(&:id)
    old_users = users.reject { |user| list.include?(user.id) }
    
    logger.debug "New users: #{new_users}"
    logger.debug "Old users: #{old_users}"
    
    self.class.transaction do
      # delete old assignments
      if old_users.any?
        assignments.find(:all, :conditions => ["user_id IN (?)", old_users.collect(&:id)]).each(&:destroy)
      end
      # create new assignments
      new_users.each do |id|
        user = User.find(id)
        if user.blank?
          errors.add(:user_list)
        else
          if  user == User.current_user
            # current_user will accept, when he puts himself to the list of users
            self.assignments.build :user => user, :accepted => true
          else
            # normal assignement
            self.assignments.build :user => user
          end
        end
      end
    end
  end
  
  def user_list
    @user_list ||= users.collect(&:id).join(", ")
  end

  private

  def update_ordergroup_stats
    if done
      users.each { |u| u.ordergroup.update_stats! if u.ordergroup }
    end
  end
end

