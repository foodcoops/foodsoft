require 'spec_helper'

describe 'product distribution', :type => :feature do
  let(:admin) { FactoryGirl.create :admin }
  let(:user_a) { FactoryGirl.create :user, groups: [FactoryGirl.create(:ordergroup)] }
  let(:user_b) { FactoryGirl.create :user, groups: [FactoryGirl.create(:ordergroup)] }
  let(:supplier) { FactoryGirl.create :supplier }
  let(:article) { FactoryGirl.create :article, supplier: supplier, unit_quantity: 5 }
  let(:order) { FactoryGirl.create(:order, supplier: supplier, article_ids: [article.id]) }
  let(:oa) { order.order_articles.first }

  describe :type => :feature do
    it 'agrees to documented example', :js => true do
      # gruppe a bestellt 2(3), weil sie auf jeden fall was von x bekommen will
      login user_a
      visit new_group_order_path(:order_id => order.id)
      find("[data-increase_quantity='#{oa.id}']").click
      find("[data-increase_quantity='#{oa.id}']").click
      find("[data-increase_tolerance='#{oa.id}']").click
      find("[data-increase_tolerance='#{oa.id}']").click
      find("[data-increase_tolerance='#{oa.id}']").click
      find('input[type=submit]').click
      # gruppe b bestellt 2(0)
      login user_b
      visit new_group_order_path(:order_id => order.id)
      find("[data-increase_quantity='#{oa.id}']").click
      find("[data-increase_quantity='#{oa.id}']").click
      find('input[type=submit]').click
      # gruppe a faellt ein dass sie doch noch mehr braucht von x und aendert auf 4(1).
      login user_a
      visit edit_group_order_path(order.group_order(user_a.ordergroup), :order_id => order.id)
      find("[data-increase_quantity='#{oa.id}']").click
      find("[data-increase_quantity='#{oa.id}']").click
      find("[data-decrease_tolerance='#{oa.id}']").click
      find("[data-decrease_tolerance='#{oa.id}']").click
      # die zuteilung
      order.close!(admin)
      # Endstand: insg. Bestellt wurden 6(1)
      expect(oa.result).to == 6
      # Gruppe a bekommt 3 einheiten.
      goa_a = oa.group_order_articles.where(:ordergroup_id => user_a.ordergroup.id).first
      expect(goa_a.result).to == 3
      # gruppe b bekommt 2 einheiten.
      goa_b = oa.group_order_articles.where(:ordergroup_id => user_b.ordergroup.id).first
      expect(goa_b.result).to == 2
    end
  end

end
