# -*- coding: utf-8 -*-
class Task < ActiveRecord::Base
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments
  belongs_to :workgroup
  belongs_to :periodic_task_group

  scope :non_group, -> { where(workgroup_id: nil, done: false) }
  scope :done, -> { where(done: true) }
  scope :undone, -> { where(done: false) }

  attr_accessor :current_user_id

  # form will send user in string. responsibilities will added later
  include ActiveModel::MassAssignmentSecurity
  attr_protected :users

  validates :name, :presence => true, :length => { :minimum => 3 }
  validates :required_users, :presence => true
  validates_numericality_of :duration, :required_users, :only_integer => true, :greater_than => 0
  validates_length_of :description, maximum: 250
  validates :done, exclusion: { in: [true] }, if: :periodic?, on: :create

  before_save :exclude_from_periodic_task_group, if: :changed?, unless: :new_record?
  after_save :update_ordergroup_stats

  # Find all tasks, for which the current user should be responsible
  # but which aren't accepted yet
  def self.unaccepted_tasks_for(user)
    user.tasks.undone.where(assignments: {accepted: false})
  end

  # Find all accepted tasks, which aren't done
  def self.accepted_tasks_for(user)
    user.tasks.undone.where(assignments: {accepted: true})
  end


  # find all tasks in the next week (or another number of days)
  def self.next_assigned_tasks_for(user, number = 7)
    user.tasks.undone.where(assignments: {accepted: true}).
        where(["tasks.due_date >= ? AND tasks.due_date <= ?", Time.now, number.days.from_now])
  end

  # count tasks with not enough responsible people
  # tasks for groups the user is not a member are ignored
  def self.unassigned_tasks_for(user)
    undone.includes(:assignments, workgroup: :memberships).select do |task|
      !task.enough_users_assigned? and
          (!task.workgroup or task.workgroup.memberships.detect { |m| m.user_id == user.id })
    end
  end

  def periodic?
    not periodic_task_group.nil?
  end

  def is_assigned?(user)
    self.assignments.detect {|ass| ass.user_id == user.id }
  end
  
  def is_accepted?(user)
    self.assignments.detect {|ass| ass.user_id == user.id && ass.accepted }
  end
  
  def enough_users_assigned?
    assignments.to_a.count(&:accepted) >= required_users ? true : false
  end

  def still_required_users
    required_users - assignments.to_a.count(&:accepted)
  end

  # Get users from comma seperated ids
  # and makes the users responsible for the task
  # TODO: check for maximal number of users
  def user_list=(ids)
    list = ids.split(",").map(&:to_i)
    new_users = (list - users.collect(&:id)).uniq
    old_users = users.reject { |user| list.include?(user.id) }
    
    self.class.transaction do
      # delete old assignments
      if old_users.any?
        assignments.where(user_id: old_users.map(&:id)).each(&:destroy)
      end
      # create new assignments
      new_users.each do |id|
        user = User.find(id)
        if user.blank?
          errors.add(:user_list)
        else
          if  id == current_user_id.to_i
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

  def update_ordergroup_stats(user_ids = self.user_ids)
    Ordergroup.joins(:users).where(users: {id: user_ids}).each(&:update_stats!)
  end

  def exclude_from_periodic_task_group
    self.periodic_task_group = nil
    true
  end
end

