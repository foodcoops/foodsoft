# run from command line: "ruby test_the_plugin.rb"
#
# Testing hooks that this plugin modifies
# These tests are written to test standard ruby/rails functions
# Note that it requires access to the standard ruby/rails plugins that it modifies

# require standard gems
require 'rubygems'
require 'test/unit'

require 'active_record'
require 'action_view'
require 'active_support'

# FIXME: I want a way to test all languages at a time.
# Currently this $language flag has to be changed with every test run 
$language = "en" unless $language
require File.dirname(__FILE__) + '/../lib/lang_' + $language
require File.dirname(__FILE__) + '/../lib/localization_simplified'


class LocalizationSimplifiedTest < Test::Unit::TestCase
	include LocalizationSimplified
	def setup
		@languages=%w{chef da de en es se} #languages that should be tested
	end
	
  def test_language_file
    assert_equal $language,LocalizationSimplified::About[:lang]
    assert_kind_of Class,LocalizationSimplified::About.class
		assert_kind_of Class,LocalizationSimplified::ActiveRecord::ErrorMessages.class
		assert_kind_of Class,LocalizationSimplified::DateHelper::Texts.class
		assert_kind_of Class,LocalizationSimplified::NumberHelper::CurrencyOptions.class
		assert_kind_of Class,LocalizationSimplified::ArrayHelper::ToSentenceTexts.class
  end
	
	
	def test_active_record_hooks_should_be_present
		expect =LocalizationSimplified::ActiveRecord::ErrorMessages
		model  = ::ActiveRecord::Errors.default_error_messages
		assert_equal expect[:inclusion],    model[:inclusion]
		assert_equal expect[:exclusion],    model[:exclusion]
		assert_equal expect[:invalid],      model[:invalid]
		assert_equal expect[:confirmation], model[:confirmation]
		assert_equal expect[:accepted],     model[:accepted]
		assert_equal expect[:empty],        model[:empty]
		assert_equal expect[:blank],        model[:blank]
		assert_equal expect[:too_long],     model[:too_long]
		assert_equal expect[:too_short],    model[:too_short]
		assert_equal expect[:wrong_length], model[:wrong_length]
		assert_equal expect[:taken],        model[:taken]
		assert_equal expect[:not_a_number], model[:not_a_number]

		#expect's additions is supposed to not exist on ActiveRecord before expect is added 
		assert_equal expect[:error_translation], model[:error_translation]
		assert_equal expect[:error_header],      model[:error_header]
		assert_equal expect[:error_subheader],   model[:error_subheader]
	end

	def test_active_record_is_loaded_with_plugin_hooks
		assert_not_nil ::ActiveRecord::Errors.default_error_messages[:error_translation]
		assert_not_nil ::ActiveRecord::Errors.default_error_messages[:error_header]
		assert_not_nil ::ActiveRecord::Errors.default_error_messages[:error_subheader]
	end
		
		
	#note that this test will fail if currency format is different from "$1.234,00"
	def test_number_to_currency
		assert ActionView::Helpers::NumberHelper
		obj =  ActionView::Base.new
		assert_respond_to obj, 'number_to_currency'
		assert_respond_to obj, 'orig_number_to_currency'
		
		assert_equal      "$1,234,567,890.51", obj.number_to_currency(1234567890.506), "NOTE: This currency test should fail if locale has different currency format"
	end
	
	def test_to_sentence
		options =LocalizationSimplified::ArrayHelper::ToSentenceTexts
		arr = [1,2,3]
		s   = "1, 2" + ("," unless options[:skip_last_comma]).to_s + " "+ options[:connector].to_s + " 3"
		assert_equal s, arr.to_sentence
		# FIXME: test below fails for some reason I cannot understand
		# assert_respond_to  arr, orig_to_sentence
	end
	
	def test_time_ago_in_words
		assert ActionView::Helpers::NumberHelper
		a = ActionView::Base.new
		messages =LocalizationSimplified::DateHelper::Texts
		assert messages[:less_than_a_minute]                                         , a.time_ago_in_words(3.seconds.ago, false)
		assert format( messages[:less_than_x_seconds], 5 )                           , a.time_ago_in_words(3.seconds.ago,  true)
		assert format( messages[:less_than_x_seconds], 10 )                          , a.time_ago_in_words(9.seconds.ago,  true)
		assert format( messages[:less_than_x_seconds], 20 )                          , a.time_ago_in_words(20.seconds.ago, true)
		assert messages[:half_a_minute]                                              , a.time_ago_in_words(31.seconds.ago, true)
		assert messages[:less_than_a_minute]                                         , a.time_ago_in_words(50.seconds.ago)
		assert messages[:one_minute]                                                 , a.time_ago_in_words(80.seconds.ago)
		assert messages[:one_hour]                                                   , a.time_ago_in_words(50.minutes.ago)
		assert messages[:one_day]                                                    , a.time_ago_in_words(1.day.ago)
		assert messages[:one_month]                                                  , a.time_ago_in_words(1.month.ago)
		assert messages[:one_year]                                                   , a.time_ago_in_words(1.year.ago)
		# FIXME: 3 tests below are not tested, as they require more logic in the test
		# Please fix, if possible and simple
#		assert format(messages[:x_minutes], distance_in_minutes)                     , a.time_ago_in_words(4.minutes.ago)
#		assert format( messages[:x_hours], (distance_in_minutes.to_f / 60.0).round ) , a.time_ago_in_words(4.hours.ago)
#		assert format( messages[:x_days], (distance_in_minutes / 1440).round )       , a.time_ago_in_words(4.days.ago)
	end
	
	def test_time_is_localized
		t = Time.parse('2006-08-23 11:55:44')
		assert_equal  "Wed Aug 23 11:55:44 Romance Daylight Time 2006", t.to_s, "NOTE: This test should fail if locale has different daynames, monthnames, timezone"
		
	end
	
	def test_date_is_localized
		
	end
end
