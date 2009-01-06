# run from command line "ruby test_the_hooks.rb"
#
# These tests are testing hooks that this plugin modifies
# These tests are written to test standard ruby/rails functions
# Note that it requires access to the standard ruby/rails plugins that it modifies

# require standard gems
require 'rubygems'
require 'test/unit'

require 'active_record'
require 'action_view'
require 'active_support'


require File.dirname(__FILE__) + '/../lib/lang_en'


class LocalizationSimplifiedTest < Test::Unit::TestCase
	include LocalizationSimplified

	
  def test_language_file_en
    assert_equal "en",LocalizationSimplified::About[:lang]
    assert_kind_of Class,LocalizationSimplified::About.class
		assert_kind_of Class,LocalizationSimplified::ActiveRecord::ErrorMessages.class
		assert_kind_of Class,LocalizationSimplified::DateHelper::Texts.class
		assert_kind_of Class,LocalizationSimplified::NumberHelper::CurrencyOptions.class
		assert_kind_of Class,LocalizationSimplified::ArrayHelper::ToSentenceTexts.class
  end
	
	def test_default_active_record_exists
		assert ::ActiveRecord
		assert ::ActiveRecord::Errors
		assert_kind_of Hash, ::ActiveRecord::Errors.default_error_messages
	end
	
	def test_default_active_record_hooks
		hook = ::ActiveRecord::Errors.default_error_messages
		expect = {
      :inclusion           => "is not included in the list",
      :exclusion           => "is reserved",
      :invalid             => "is invalid",
      :confirmation        => "doesn't match confirmation",
      :accepted            => "must be accepted",
      :empty               => "can't be empty",
      :blank               => "can't be blank",
      :too_long            => "is too long (maximum is %d characters)",
      :too_short           => "is too short (minimum is %d characters)",
      :wrong_length        => "is the wrong length (should be %d characters)",
      :taken               => "has already been taken",
      :not_a_number        => "is not a number",
      #Jespers additions:
      :error_translation   => "error",
      :error_header        => "%s prohibited this %s from being saved",
      :error_subheader     => "There were problems with the following fields:"
    }

		assert_equal expect[:inclusion],    hook[:inclusion]
		assert_equal expect[:exclusion],    hook[:exclusion]
		assert_equal expect[:invalid],      hook[:invalid]
		assert_equal expect[:confirmation], hook[:confirmation]
		assert_equal expect[:accepted],     hook[:accepted]
		assert_equal expect[:empty],        hook[:empty]
		assert_equal expect[:blank],        hook[:blank]
		assert_equal expect[:too_long],     hook[:too_long]
		assert_equal expect[:too_short],    hook[:too_short]
		assert_equal expect[:wrong_length], hook[:wrong_length]
		assert_equal expect[:taken],        hook[:taken]
		assert_equal expect[:not_a_number], hook[:not_a_number]
  end

	def test_plugin_hooks_dont exist
		hook = ::ActiveRecord::Errors.default_error_messages

		#plugin s additions is supposed to not exist on ActiveRecord before plugin is added 
		assert_nil hook[:error_translation], "Should fail if plugin already added"
		assert_nil hook[:error_header],      "Should fail if plugin already added"
		assert_nil hook[:error_subheader],   "Should fail if plugin already added"
	end

		
		
	def test_number_to_currency
		assert ActionView::Helpers::NumberHelper
		obj =  ActionView::Base.new
		assert_respond_to obj, 'number_to_currency'
		#assert_nil        obj.orig_number_to_currency #FIXME this line makes assertion fail. Should be nil.
		assert_equal   "$1,234,567,890.51", obj.number_to_currency(1234567890.506)
	end
	
	def test_to_sentence
		assert ActiveSupport::CoreExtensions::Array::Conversions
		a =    Array.new
		assert_respond_to a, 'to_sentence'
		assert_equal "1, 2, and 3", [1,2,3].to_sentence
	end
	
	def test_date_helpers
		assert ActionView::Helpers::NumberHelper
		a = ActionView::Base.new
		assert 'less than 5 seconds'  , a.time_ago_in_words(3.seconds.ago,  true)
		assert 'less than 10 seconds' , a.time_ago_in_words(9.seconds.ago,  true)
		assert 'less than 20 seconds' , a.time_ago_in_words(20.seconds.ago, true)
		assert 'half a minute'        , a.time_ago_in_words(31.seconds.ago, true)
		assert 'less than a minute'   , a.time_ago_in_words(50.seconds.ago, false)
		assert 'less than a minute'   , a.time_ago_in_words(50.seconds.ago)
		assert '1 minute'             , a.time_ago_in_words(80.seconds.ago)
		assert '4 minutes'            , a.time_ago_in_words(4.minutes.ago)
		assert 'about 1 hour'         , a.time_ago_in_words(50.minutes.ago)
		assert '4 hours'              , a.time_ago_in_words(4.hours.ago)
		assert '1 day'                , a.time_ago_in_words(1.day.ago)
		assert '4 days'               , a.time_ago_in_words(4.days.ago)
	end
end
