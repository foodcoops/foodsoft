class PlannedTaskType < ApplicationRecord
  self.table_name = "v2_planned_task_types"

  # belongs_to :workgroup, optional: true

  validates_presence_of :name

  # scope :ordered, -> { order(:name) }
end
