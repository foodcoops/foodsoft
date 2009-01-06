module ActiveRecord
  module Acts
    module Ordered
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      class InvalidDirection < Exception
      end
      
      module ClassMethods
        def acts_as_ordered(options = {})
          options.assert_valid_keys :order, :wrap, :condition, :scope, :ignore_sti
          
          options[:order]     = options[:order] ? "#{options[:order]}, #{primary_key}" : primary_key
          options[:condition] = options[:condition].to_proc if options[:condition].is_a?(Symbol)
          options[:scope]     = "#{options[:scope]}_id".to_sym if options[:scope].is_a?(Symbol) && options[:scope].to_s !~ /_id$/
          
          cattr_accessor :_acts_as_ordered_options
          self._acts_as_ordered_options = options
          
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        def ordered_scope_condition
          scope = self.class._acts_as_ordered_options[:scope]
          
          return if scope.nil?
          
          if scope.is_a?(Symbol)
            { scope => send(scope) }
          else
            interpolate_sql(scope)
          end
        end
        
        def adjacent_id(number)
          ids = ordered_ids
          ids.reverse! if number < 0
          index = ids.index(self.id)
          
          if self.class._acts_as_ordered_options[:wrap]
            ids[(index + number.abs) % ids.size]
          else
            ids[index + number.abs] || ids.last
          end
        end
        
        def ordered_ids
          conditions, options = [], self.class._acts_as_ordered_options
          
          if !options[:ignore_sti] && !self.class.descends_from_active_record?
            conditions << self.class.send(:type_condition)
          end
          
          unless ordered_scope_condition.blank?
            conditions << self.class.send(:sanitize_sql, ordered_scope_condition)
          end
          
          sql_conditions = "WHERE #{conditions.join(') AND (')}" if conditions.any?
          
          connection.select_values("SELECT #{self.class.primary_key} FROM #{self.class.table_name} #{sql_conditions} ORDER BY #{options[:order]}").map!(&:to_i)
        end
        
        def adjacent_record(options = {})
          previous_record, number, ordered_options = self, options.delete(:number), self.class._acts_as_ordered_options
          
          loop do
            adjacent_record = self.class.base_class.find(previous_record.adjacent_id(number), options.dup)
            matches = ordered_options[:condition] ? ordered_options[:condition].call(adjacent_record) : true
            
            return adjacent_record if matches
            return self if adjacent_record == self # If the search for a matching record failed
            return self if previous_record == adjacent_record # If we've found the same adjacent_record twice
            
            previous_record = adjacent_record
            number = number < 0 ? -1 : 1
          end
        end
        
        def current_total
          self.class.base_class.count :conditions => ordered_scope_condition
        end
        
        def current_index
          ordered_ids.index(id)
        end
        
        def current_position
          current_index + 1
        end
        
        def next(options = {})
          adjacent_record(options.reverse_merge(:number => 1))
        end
        
        def previous(options = {})
          options = options.reverse_merge(:number => 1)
          options[:number] = -options[:number]
          adjacent_record(options)
        end
        
        def find_by_direction(direction, options = {})
          direction = direction.to_s
          ['next', 'previous'].include?(direction) ? send(direction, options) : raise(InvalidDirection.new(direction))
        end
        
        def first?
          id == first_id
        end
        
        def last?
          id == last_id
        end
        
        def first
          self.class.base_class.find(first_id)
        end
        
        def last
          self.class.base_class.find(last_id)
        end
        
        def first_id
          ordered_ids.first
        end
        
        def last_id
          ordered_ids.last
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Ordered)
